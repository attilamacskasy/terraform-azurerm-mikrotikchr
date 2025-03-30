# set-azure-secret.ps1

param (
    [string]$Repo = "attilamacskasy/terraform-azurerm-mikrotikchr",
    [string]$SecretName = "AZURE_CREDENTIALS_ADMIN"
)

# Optional: Create a new SP (or paste your own credentials here)
$sp = az ad sp create-for-rbac --name "gh-actions-admin" --role "Contributor" --sdk-auth | ConvertFrom-Json

# Output the SP JSON
$spJson = $sp | ConvertTo-Json -Compress

# Set the secret using GitHub CLI
$env:GH_TOKEN = gh auth status --show-token | Select-String 'Token: (\w+)' | ForEach-Object { $_.Matches[0].Groups[1].Value }
Write-Output $spJson | gh secret set $SecretName --repo $Repo

Write-Host "Secret '$SecretName' has been set for $Repo"
