$ErrorActionPreference = "Stop"

Write-Host "Running GitHub Actions workflow: 06_Prepare_CHR_Config.yml"

# Ensure GitHub CLI is available
if (-not (Get-Command "gh" -ErrorAction SilentlyContinue)) {
    Write-Error "GitHub CLI not found. Please install GitHub CLI from https://cli.github.com/"
    exit 1
}

# Check auth
$ghAuthStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "GitHub CLI not authenticated. Starting login..."
    gh auth login
}

# Trigger workflow
Write-Host "Dispatching workflow '06_Prepare_CHR_Config.yml'..."
gh workflow run "06_Prepare_CHR_Config.yml"

$repoFullName = gh repo view --json fullName -q .fullName
Write-Host "Workflow dispatched. You can monitor progress here:"
Write-Host "https://github.com/$repoFullName/actions"
