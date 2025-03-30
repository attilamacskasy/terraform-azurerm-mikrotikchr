$ErrorActionPreference = "Stop"

# Helper: Check and optionally install GitHub CLI
function Test-AndInstall-GitHubCLI {
    if (-not (Get-Command "gh" -ErrorAction SilentlyContinue)) {
        Write-Host "GitHub CLI is not installed on this system."

        $installerUrl = "https://github.com/cli/cli/releases/latest/download/gh_2.45.0_windows_amd64.msi"
        $downloadsFolder = [Environment]::GetFolderPath("MyDocuments").Replace("Documents", "Downloads")
        $installerPath = Join-Path $downloadsFolder "GitHubCLI.msi"

        Write-Host "Downloading GitHub CLI installer to:"
        Write-Host "  $installerPath"
        Start-BitsTransfer -Source $installerUrl -Destination $installerPath

        Write-Host "`nGitHub CLI installer downloaded successfully."
        Write-Host "Installer path:"
        Write-Host "  $installerPath"

        $response = Read-Host "Do you want to run the GitHub CLI installer now? (Y/N)"
        if ($response -match '^[Yy]$') {
            Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`"" -Wait
            Write-Host "Installer launched. Please complete installation, then re-run this script."
        } else {
            Write-Host "You chose not to run the installer. Please install manually and re-run this script."
        }

        Pause
        exit 0
    } else {
        Write-Host "GitHub CLI is already installed."
    }
}

# Check for GitHub CLI
Test-AndInstall-GitHubCLI

# Load parameters
$paramFilePath = "$PSScriptRoot\..\deploy-params.json"
if (-not (Test-Path $paramFilePath)) {
    Write-Error "ERROR: deploy-params.json not found at $paramFilePath"
    exit 1
}

$Params = Get-Content $paramFilePath | ConvertFrom-Json
$ServicePrincipalName = $Params.sp_name
$SecretName = "AZURE_CREDENTIALS_ADMIN"
$Repo = "attilamacskasy/terraform-azurerm-mikrotikchr"

# Check for Azure CLI
if (-not (Get-Command "az" -ErrorAction SilentlyContinue)) {
    Write-Error "Azure CLI not found. Please install from https://aka.ms/installazurecliwindowsx64 and try again."
    exit 1
}

# Login to Azure
Write-Host "Logging into Azure..."
az account show > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    az login --only-show-errors | Out-Null
}

# Get IDs
$subscriptionId = az account show --query id -o tsv
$tenantId = az account show --query tenantId -o tsv

# Get SP
$spId = az ad sp list --display-name $ServicePrincipalName --query "[0].appId" -o tsv
if (-not $spId) {
    Write-Error "Service Principal '$ServicePrincipalName' not found. Please run the creation script first."
    exit 1
}

# Reset secret
Write-Host "Generating new client secret for '$ServicePrincipalName'..."
$spSecret = az ad sp credential reset --id $spId --query password -o tsv
if (-not $spSecret) {
    Write-Error "Failed to generate new client secret."
    exit 1
}

# Format as GitHub Actions JSON
$spCredentials = @{
    clientId       = $spId
    clientSecret   = $spSecret
    subscriptionId = $subscriptionId
    tenantId       = $tenantId
} | ConvertTo-Json -Compress

# Check GitHub CLI auth
$ghLoggedIn = $false
try {
    gh auth status --hostname github.com 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        $ghLoggedIn = $true
    }
} catch {
    $ghLoggedIn = $false
}

if (-not $ghLoggedIn) {
    Write-Host "You are not logged into GitHub CLI."
    $response = Read-Host "Do you want to log in now with 'gh auth login'? (Y/N)"
    if ($response -match '^[Yy]$') {
        gh auth login
        if ($LASTEXITCODE -ne 0) {
            Write-Error "GitHub CLI login failed or was canceled. Please try again."
            exit 1
        }
    } else {
        Write-Host "Skipping secret creation. You must log in with 'gh auth login' before setting secrets."
        exit 1
    }
}

# Set the secret
Write-Host "Setting GitHub secret '$SecretName' in repo '$Repo'..."
$spCredentials | gh secret set $SecretName --repo $Repo

Write-Host "Secret '$SecretName' has been created or updated in repository '$Repo'."
