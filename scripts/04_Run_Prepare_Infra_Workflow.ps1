$ErrorActionPreference = "Stop"

$workflowFileName = "04_Prepare_Infra.yml"
$repo = "attilamacskasy/terraform-azurerm-mikrotikchr"

Write-Host ""
Write-Host "HOW TO RUN THIS WORKFLOW MANUALLY"
Write-Host "-----------------------------------"
Write-Host "1. Open your browser and go to:"
Write-Host "   https://github.com/$repo/actions"
Write-Host ""
Write-Host "2. Click on '04 Prepare Azure Infra for CHR Deployment (04_Prepare_Infra.yml)'"
Write-Host "3. Hit the 'Run workflow' button"
Write-Host ""

# Ask if they want to run it from PowerShell instead
$response = Read-Host "Would you like to trigger this workflow from PowerShell instead? (Y/N)"
if ($response -notmatch '^[Yy]$') {
    Write-Host "Okay! Exiting without running the workflow."
    exit 0
}

# Check for GitHub CLI
if (-not (Get-Command "gh" -ErrorAction SilentlyContinue)) {
    Write-Error "GitHub CLI is not installed. Please install it from https://cli.github.com/ and try again."
    exit 1
}

# Check GitHub authentication
try {
    gh auth status --hostname github.com 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Not authenticated."
    }
} catch {
    Write-Host "You are not logged into GitHub CLI."
    $ghLogin = Read-Host "Do you want to log in now with 'gh auth login'? (Y/N)"
    if ($ghLogin -match '^[Yy]$') {
        gh auth login
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Login failed or cancelled. Exiting."
            exit 1
        }
    } else {
        Write-Host "You chose not to log in. Exiting."
        exit 1
    }
}

# Trigger the workflow
Write-Host "Triggering GitHub Actions workflow '$workflowFileName' in repo '$repo'..."
gh workflow run $workflowFileName --repo $repo

Write-Host "Workflow trigger sent. You can monitor progress at:"
Write-Host "   https://github.com/$repo/actions"
