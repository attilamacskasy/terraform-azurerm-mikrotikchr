<#
.SYNOPSIS
Generate a secure random admin password, update deploy-params.json on the runner,
and optionally set it as a GitHub repository secret using the `gh` CLI.

DESCRIPTION
- Generates a password meeting complexity rules (upper/lower/digit/special).
- Replaces the `os_profile_admin_password` value in the JSON file.
- If `GITHUB_REPOSITORY` and `GITHUB_TOKEN` (or GH_TOKEN) are present and
  `gh` CLI is installed, attempts `gh secret set <name> --repo $GITHUB_REPOSITORY`.

USAGE (local or CI):
pwsh -File scripts\01_Generate_And_Set_AdminPassword.ps1

In GitHub Actions, make sure the runner has `gh` installed and an
admin token available (set to the `GITHUB_TOKEN` or a PAT) so the script
can call `gh secret set`.
#>

param(
    [string]$ParamFilePath = "$PSScriptRoot\..\deploy-params.json",
    [int]$Length = 20,
    [string]$SecretName = "OS_ADMIN_PASSWORD",
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

function New-RandomPassword {
    param(
        [int]$length = 20
    )

    # Character sets
    $upper = ([char[]]'ABCDEFGHIJKLMNOPQRSTUVWXYZ')
    $lower = ([char[]]'abcdefghijklmnopqrstuvwxyz')
    $digits = ([char[]]'0123456789')
    $special = ([char[]]'!@#$%&*()-_=+[]{};:,.<>?')

    # Ensure at least one from each set
    $seed = @()
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()

    $getRandomIndex = {
        param($max)
        $bytes = New-Object 'System.Byte[]' 4
        $rng.GetBytes($bytes)
        $val = [System.BitConverter]::ToUInt32($bytes,0)
        return [int]($val % $max)
    }

    $seed += $upper[(& $getRandomIndex $upper.Length)]
    $seed += $lower[(& $getRandomIndex $lower.Length)]
    $seed += $digits[(& $getRandomIndex $digits.Length)]
    $seed += $special[(& $getRandomIndex $special.Length)]

    $all = $upper + $lower + $digits + $special

    for ($i = $seed.Count; $i -lt $length; $i++) {
        $seed += $all[(& $getRandomIndex $all.Length)]
    }

    # Shuffle
    $shuffled = $seed | Sort-Object { Get-Random }
    return -join $shuffled
}

Write-Host "Reading parameters file: $ParamFilePath"
if (-not (Test-Path $ParamFilePath)) {
    Write-Error "Parameter file not found: $ParamFilePath"
    exit 1
}

# Load JSON
$raw = Get-Content -Raw -Path $ParamFilePath
try {
    $json = $raw | ConvertFrom-Json
} catch {
    Write-Error ("Failed to parse JSON from {0}: {1}" -f $ParamFilePath, $_)
    exit 1
}

# Generate password
$password = New-RandomPassword -length $Length
Write-Host "Generated password (will not be printed again): [REDACTED]"

# Update JSON
$json.os_profile_admin_password = $password

# Save the file (pretty printed)
try {
    $json | ConvertTo-Json -Depth 10 | Set-Content -Path $ParamFilePath -Encoding UTF8
    Write-Host "Updated $ParamFilePath with new admin password (on runner)."
} catch {
    Write-Error "Failed to write updated JSON: $_"
    exit 1
}

# Attempt to save as GitHub Secret using gh CLI if possible
$repo = $env:GITHUB_REPOSITORY
$token = $env:GITHUB_TOKEN
if (-not $token) { $token = $env:GH_TOKEN }
$ghPresent = $false
try {
    $ghPath = Get-Command gh -ErrorAction SilentlyContinue
    if ($ghPath) { $ghPresent = $true }
} catch {
    $ghPresent = $false
}

if ($repo -and $token) {
    if ($ghPresent) {
        Write-Host "Found GITHUB_REPOSITORY and token; attempting to set repo secret '$SecretName' using gh..."
        try {
            # Note: gh will use its own auth; ensure GH_TOKEN is exported or runner has gh auth setup
            $env:GH_TOKEN = $token
            gh secret set $SecretName --body "$password" --repo $repo
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Successfully set repository secret '$SecretName' for $repo."
            } else {
                Write-Warning "gh secret set exited with code $LASTEXITCODE. Secret may not have been set."
            }
        } catch {
            Write-Warning "Failed to run gh secret set: $_"
            Write-Host "You can set the secret manually with: gh secret set $SecretName --body <password> --repo $repo"
        }
    } else {
        Write-Warning "GITHUB_REPOSITORY and token are present but 'gh' CLI was not found."
        Write-Host "To set the repo secret programmatically from the runner you can either:"
        Write-Host " - Install and authenticate 'gh' and rerun this script, or"
        Write-Host " - Use the GitHub REST API to create the secret (requires encryption with repo public key)."
        Write-Host "Printing the password so the pipeline can capture it and call gh or API (note: sensitive):"
        Write-Output $password
    }
} else {
    Write-Host "GITHUB_REPOSITORY or token not present; skipping automatic GitHub secret creation."
    Write-Host "Password is printed once to stdout so you can capture it in CI and store as a secret."
    Write-Output $password
}

Write-Host "Done. The updated parameters file contains the generated password."

if (-not ($repo -and $token)) {
    Write-Host "Recommended: store the password as a repository secret named '$SecretName' and remove the value from public repo after deployment."
}

# Optionally, if user wants to echo path
Write-Host "Parameter file path: $ParamFilePath"

exit 0
