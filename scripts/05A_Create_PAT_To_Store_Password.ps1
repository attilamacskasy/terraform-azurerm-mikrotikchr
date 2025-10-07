<#
.SYNOPSIS
Ensures a GitHub token with repo scope exists for the current user and stores it
as a repository secret REPO_PAT so the pipeline can create/update secrets (e.g., OS_ADMIN_PASSWORD).

.DESCRIPTION
This script relies on the GitHub CLI (gh):
- Authenticates the user (device/web flow) if not already logged in.
- Requests/refreshes the repo scope for the token used by gh.
- Retrieves the token via `gh auth token`.
- Stores the token in the target repository as a secret named REPO_PAT using `gh secret set`.

NOTES
- There is no public GitHub API to programmatically create a classic PAT non-interactively.
  This script uses the gh CLI's OAuth token, which is sufficient for repository secret operations
  when `repo` (or `public_repo` for public repos) scope is granted.
- You must be an admin on the target repository to set secrets.

USAGE
pwsh -File scripts/05A_Create_PAT_To_Store_Password.ps1 -Repository <owner/repo>

If -Repository is omitted, the script attempts to autodetect it from:
- $env:GITHUB_REPOSITORY
- git remote origin URL

#>

param(
    [string]$Repository,
    [ValidateSet('repo','public_repo')]
    [string]$Scope = 'repo',
    [switch]$ForceRefreshScopes
)

$ErrorActionPreference = 'Stop'

function Fail($msg) {
    Write-Error $msg
    exit 1
}

function Test-GhCli {
    $cmd = Get-Command gh -ErrorAction SilentlyContinue
    if (-not $cmd) { return $false }
    return $true
}

function Get-RepoSlugFromGit {
    try {
        $url = git remote get-url origin 2>$null
        if (-not $url) { return $null }
        # Normalize
        if ($url -match 'github.com[:/](?<owner>[^/]+?)/(?<repo>[^/]+?)(\.git)?$') {
            $owner = $Matches['owner']
            $repo = $Matches['repo']
            return "$owner/$repo"
        }
        return $null
    } catch { return $null }
}

# Resolve repository slug
if (-not $Repository -or $Repository -eq '') {
    if ($env:GITHUB_REPOSITORY) {
        $Repository = $env:GITHUB_REPOSITORY
    } else {
        $Repository = Get-RepoSlugFromGit
    }
}

if (-not $Repository) {
    Write-Host "Could not determine repository slug automatically."
    $Repository = Read-Host "Enter repository in the form 'owner/repo'"
}

if (-not $Repository -or $Repository -notmatch '^[^/]+/[^/]+$') {
    Fail "Invalid repository identifier. Expected 'owner/repo'. Got: '$Repository'"
}

Write-Host "Target repository: $Repository"

# Ensure gh CLI is available
if (-not (Test-GhCli)) {
    Fail "GitHub CLI ('gh') is not installed. Install from https://cli.github.com/ and re-run."
}

# Check gh auth status; if not logged in, perform login
$needLogin = $false
try {
    gh auth status -h github.com --show-token 1>$null 2>$null
} catch {
    $needLogin = $true
}

if ($needLogin) {
    Write-Host "You're not logged in with gh. Starting device login flow..."
    # -s to request needed scope during login
    gh auth login -h github.com -s $Scope -w
}

# Optionally refresh scopes to ensure we have the requested one
if ($ForceRefreshScopes) {
    Write-Host "Refreshing gh auth scopes to include: $Scope"
    gh auth refresh -h github.com -s $Scope
} else {
    # Try refreshing scopes quietly; if it fails, we'll prompt login
    try { gh auth refresh -h github.com -s $Scope 1>$null } catch { }
}

# Retrieve the token used by gh
Write-Host "Retrieving authenticated token from gh..."
$token = gh auth token 2>$null
if (-not $token) {
    Fail "Failed to retrieve gh auth token. Try re-running with -ForceRefreshScopes or re-login via 'gh auth login'."
}

# Never print the token; mask any accidental output
Write-Host "Token acquired via gh (value will not be displayed)."

# Attempt to set repository secret
Write-Host "Setting repository secret 'REPO_PAT' on $Repository ..."
try {
    $env:GH_TOKEN = $token
    # Using gh secret avoids needing to handle encryption of the value
    gh secret set REPO_PAT --repo $Repository --body "$token"
    if ($LASTEXITCODE -ne 0) {
        Fail "Failed to set repository secret REPO_PAT (exit code $LASTEXITCODE). Ensure you have admin access to the repo."
    }
    Write-Host "Successfully set repository secret 'REPO_PAT' for $Repository."
} catch {
    Fail "Error while setting repository secret: $_"
}

Write-Host "Done. Your workflow can now use secrets.REPO_PAT to create/update other secrets."
