$ErrorActionPreference = "Stop"

# Load parameters
$paramFilePath = "$PSScriptRoot\..\deploy-params.json"
if (-not (Test-Path $paramFilePath)) {
    Write-Error "ERROR: deploy-params.json not found at $paramFilePath"
    exit 1
}

$Params = Get-Content $paramFilePath | ConvertFrom-Json
$ServicePrincipalName = $Params.sp_name

# Check if az CLI is available
if (-not (Get-Command "az" -ErrorAction SilentlyContinue)) {
    Write-Error "Azure CLI not found. Please install it from https://aka.ms/installazurecliwindowsx64 and try again."
    exit 1
}

# Login (silent if already logged in)
Write-Host "Logging into Azure..."
az account show > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    az login --only-show-errors | Out-Null
}

# Query for the SP by display name
Write-Host "Checking for Service Principal '$ServicePrincipalName'..."
$spId = az ad sp list --display-name $ServicePrincipalName --query "[0].appId" -o tsv

if (-not $spId) {
    Write-Host "Service Principal '$ServicePrincipalName' was NOT found in Azure AD."
    Write-Host "You may need to run the script '00_Create_Azure_SP_CLI.ps1' first."
    exit 0
}

# Show info and suggest checking in portal
$tenantId = az account show --query tenantId -o tsv
$portalUrl = "https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Overview/appId/$spId"

Write-Host ""
Write-Host "Service Principal '$ServicePrincipalName' exists."
Write-Host "-------------------------------------------------"
Write-Host "App ID (clientId) : $spId"
Write-Host "Tenant ID         : $tenantId"
Write-Host "-------------------------------------------------"
Write-Host ""
Write-Host "You can view it in the Azure Portal here:"
Write-Host "  $portalUrl"
Write-Host ""
Write-Host "Navigate to: Azure Active Directory ==> App registrations ==> search for '$ServicePrincipalName'"
