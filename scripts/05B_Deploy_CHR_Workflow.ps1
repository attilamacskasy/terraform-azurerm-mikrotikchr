$workflowFileName = "05B_Deploy_CHR.yml"
$repo = "attilamacskasy/terraform-azurerm-mikrotikchr"

Write-Host ""
Write-Host " Terraform Apply CHR to Azure via GitHub Actions - Based on saved Terraform plan file (as artifact)"
Write-Host "------------------------------------------"
Write-Host "You can also run this manually at:"
Write-Host "  https://github.com/$repo/actions"
Write-Host ""

$response = Read-Host "Do you want to trigger this workflow from PowerShell now? (Y/N)"
if ($response -notmatch '^[Yy]$') {
    Write-Host "Okay, exiting."
    exit 0
}

Write-Host " Triggering $workflowFileName on GitHub..."
gh workflow run $workflowFileName --repo $repo

Write-Host "`n Done. Monitor the run at:"
Write-Host "   https://github.com/$repo/actions"
