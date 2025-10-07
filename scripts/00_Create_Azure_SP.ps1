$ErrorActionPreference = "Stop"

# Function to check and install Azure CLI
function Test-AndInstall-AzCli {
    if (-not (Get-Command "az" -ErrorAction SilentlyContinue)) {
        Write-Host "Azure CLI is not installed on this system."

        $installerUrl = "https://aka.ms/installazurecliwindowsx64"
        $downloadsFolder = [Environment]::GetFolderPath("MyDocuments").Replace("Documents", "Downloads")
        $installerPath = Join-Path $downloadsFolder "AzureCLI.msi"

        Write-Host "Downloading Azure CLI installer to:"
        Write-Host "  $installerPath"
        Start-BitsTransfer -Source $installerUrl -Destination $installerPath

        Write-Host "`nAzure CLI installer downloaded successfully."
        Write-Host "Installer path:"
        Write-Host "  $installerPath"

        $response = Read-Host "Do you want to run the installer now? (Y/N)"
        if ($response -match '^[Yy]$') {
            Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`"" -Wait
            Write-Host "Installer launched. Please complete the installation and re-run this script."
            Write-Host "Remember to restart PowerShell window after installation completed."
        } else {
            Write-Host "You chose not to run the installer. Please install manually and re-run this script."
            Write-Host "Remember to restart PowerShell window after installation completed."
        }

        Pause
        exit 0
    } else {
        Write-Host "Azure CLI is already installed."
    }
}

# Check for Azure CLI
Test-AndInstall-AzCli

# Load parameters from deploy-params.json
$paramFilePath = "$PSScriptRoot\..\deploy-params.json"
if (-not (Test-Path $paramFilePath)) {
    Write-Error "ERROR: deploy-params.json not found at $paramFilePath"
    exit 1
}

$Params = Get-Content $paramFilePath | ConvertFrom-Json
$ResourceGroup = $Params.resource_group
$Location = $Params.location
$ServicePrincipalName = $Params.sp_name

# Login
Write-Host "Logging in to Azure..."
az login --only-show-errors | Out-Null

# Determine subscription to use.
# If deploy-params.json contains subscription_id or subscriptionId then use it without prompting.
# Otherwise prompt the user to interactively pick one of the subscriptions available to the signed-in account.
$specifiedSub = $null
if ($null -ne $Params.subscription_id -and $Params.subscription_id -ne "") {
    $specifiedSub = $Params.subscription_id
} elseif ($null -ne $Params.subscriptionId -and $Params.subscriptionId -ne "") {
    $specifiedSub = $Params.subscriptionId
}

if ($specifiedSub) {
    Write-Host "Using subscription from deploy-params.json: $specifiedSub"
    try {
        az account set --subscription $specifiedSub --only-show-errors | Out-Null
    } catch {
        Write-Error "Failed to set subscription to '$specifiedSub'. Ensure it is valid and you have access."
        exit 1
    }
    $subscriptionId = $specifiedSub
} else {
    $allSubsJson = az account list --all -o json
    try {
        $allSubs = $allSubsJson | ConvertFrom-Json
    } catch {
        Write-Error "Failed to read subscriptions from Azure CLI."
        exit 1
    }

    if (-not $allSubs -or $allSubs.Count -eq 0) {
        Write-Error "No subscriptions found for the signed-in account."
        exit 1
    }

    if ($allSubs.Count -eq 1) {
        $subscriptionId = $allSubs[0].id
        Write-Host "Only one subscription found. Using: $($allSubs[0].name) ($subscriptionId)"
        az account set --subscription $subscriptionId --only-show-errors | Out-Null
    } else {
        Write-Host "Select an Azure subscription to use:"
        for ($i = 0; $i -lt $allSubs.Count; $i++) {
            $s = $allSubs[$i]
            $idx = $i + 1
            $isDefault = if ($s.isDefault) { "(Default)" } else { "" }
            Write-Host "[$idx] $($s.name) - $($s.id) $isDefault"
        }

        do {
            $choice = Read-Host "Enter the number of the subscription to use"
            $valid = $false
            if ($choice -match '^\d+$') {
                $ci = [int]$choice
                if ($ci -ge 1 -and $ci -le $allSubs.Count) { $valid = $true }
            }
            if (-not $valid) { Write-Host "Invalid selection, please try again." }
        } while (-not $valid)

        $selected = $allSubs[[int]$choice - 1]
        $subscriptionId = $selected.id
        try {
            az account set --subscription $subscriptionId --only-show-errors | Out-Null
        } catch {
            Write-Error "Failed to set subscription $subscriptionId. Ensure you have access."
            exit 1
        }
        Write-Host "Selected subscription: $($selected.name) ($subscriptionId)"
    }
}

# Get tenantId and build scope
$tenantId = az account show --query tenantId -o tsv
$scope = "/subscriptions/$subscriptionId/resourceGroups/$ResourceGroup"

# Create resource group if it doesn't exist
$rgExists = az group exists --name $ResourceGroup
if ($rgExists -eq "false") {
    Write-Host "Creating Resource Group '$ResourceGroup' in location '$Location'..."
    az group create --name $ResourceGroup --location $Location --only-show-errors | Out-Null
} else {
    Write-Host "Resource Group '$ResourceGroup' already exists."
}

# Check if Service Principal exists
$existingSpId = az ad sp list --display-name $ServicePrincipalName --query "[0].appId" -o tsv

if ($existingSpId) {
    Write-Host "Service Principal '$ServicePrincipalName' already exists."
    Write-Host "-------------------------------------------------"
    Write-Host "App ID (clientId) : $existingSpId"
    Write-Host "Tenant ID         : $tenantId"
    Write-Host "Subscription ID   : $subscriptionId"
    Write-Host "-------------------------------------------------"
    Write-Host "Skipping creation."
} else {
    Write-Host "Creating Service Principal '$ServicePrincipalName' scoped to $scope..."

    $spJson = az ad sp create-for-rbac `
        --name $ServicePrincipalName `
        --role Contributor `
        --scopes $scope `
        --sdk-auth `
        --only-show-errors

    if (-not $spJson) {
        Write-Error "Failed to create Service Principal."
        exit 1
    }

    $sp = $spJson | ConvertFrom-Json

    Write-Host ""
    Write-Host "New Service Principal has been created."
    Write-Host "Please copy and store the following securely:"
    Write-Host "-------------------------------------------------"
    Write-Host "App ID (clientId) : $($sp.clientId)"
    Write-Host "Tenant ID         : $($sp.tenantId)"
    Write-Host "Client Secret     : $($sp.clientSecret)"
    Write-Host "Subscription ID   : $($sp.subscriptionId)"
    Write-Host "-------------------------------------------------"
    Read-Host "Press ENTER after you've copied the secret above. It will NOT be shown again."
}

Write-Host "Done. You can now use these credentials in GitHub Secrets or your deployment pipeline."
