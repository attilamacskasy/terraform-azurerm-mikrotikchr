# File: scripts/set-azure-secret.ps1

param (
    [string]$Repo = "attilamacskasy/terraform-azurerm-mikrotikchr",
    [string]$SecretName = "AZURE_CREDENTIALS_ADMIN"
)

$Params = Get-Content "../deploy-params.json" | ConvertFrom-Json

# Create Service Principal (or you can paste existing credentials here)
$sp = az ad sp create-for-rbac `
  --name $Params.sp_name `
  --role Contributor `
  --scopes "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$($Params.resource_group)" `
  --sdk-auth | ConvertFrom-Json

$spJson = $sp | ConvertTo-Json -Compress

# Set GitHub Secret
$env:GH_TOKEN = gh auth status --show-token | Select-String 'Token: (\w+)' | ForEach-Object { $_.Matches[0].Groups[1].Value }
echo $spJson | gh secret set $SecretName --repo $Repo

Write-Host "Secret '$SecretName' set for $Repo"