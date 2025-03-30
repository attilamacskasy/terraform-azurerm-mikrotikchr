$ErrorActionPreference = "Stop"

$SecretName = "AZURE_CREDENTIALS_ADMIN"
$Repo = "attilamacskasy/terraform-azurerm-mikrotikchr"

# Check for GitHub CLI
if (-not (Get-Command "gh" -ErrorAction SilentlyContinue)) {
    Write-Error "GitHub CLI is not installed. Please install it from https://cli.github.com/ and try again."
    exit 1
}

# Ensure user is logged into GitHub
try {
    gh auth status --hostname github.com 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Not authenticated."
    }
} catch {
    Write-Host "You are not logged into GitHub CLI."
    $response = Read-Host "Do you want to log in now with 'gh auth login'? (Y/N)"
    if ($response -match '^[Yy]$') {
        gh auth login
        if ($LASTEXITCODE -ne 0) {
            Write-Error "GitHub CLI login failed. Exiting."
            exit 1
        }
    } else {
        Write-Host "You must authenticate to check secrets. Exiting."
        exit 1
    }
}

# Check if the secret exists
$secretExists = gh secret list --repo $Repo | Select-String "^$SecretName\s"

if ($secretExists) {
    Write-Host "`n GitHub secret '$SecretName' exists in repository '$Repo'."
} else {
    Write-Host "`n GitHub secret '$SecretName' was NOT found in repository '$Repo'."
    Write-Host "You can create it by running: scripts/02_Set_GitHub_Secret.ps1"
}

# Offer to list all secrets
$response = Read-Host "`nWould you like to list all GitHub secrets in this repo? (Y/N)"
if ($response -match '^[Yy]$') {
    gh secret list --repo $Repo
}
