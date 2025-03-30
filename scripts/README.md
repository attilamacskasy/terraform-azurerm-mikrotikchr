# 🧰 Azure CHR Deployment Scripts

This folder contains PowerShell scripts that automate the setup of everything you need to deploy a MikroTik Cloud Hosted Router (CHR) on Azure — fully driven by GitHub Actions and platform-independent.

---

## ✅ What’s Included

- ✅ Prepped & compressed CHR image (`.vhd.zip`)
- ✅ GitHub Actions-ready repo structure
- ✅ Infrastructure bootstrapping:
  - Azure Resource Group
  - Storage Account + Blob Container
  - Service Principal
- ✅ Secrets created and verified in GitHub (`AZURE_CREDENTIALS_ADMIN`)
- ✅ CLI-first, cross-platform automation (Azure CLI + GitHub CLI)
- ✅ Fork-friendly, zero-local-dependency design

---

## 🌐 Designed for:

- ✅ No local tools required (runs in GitHub-hosted runners)
- ✅ GitHub-native automation
- ✅ Azure-native infrastructure
- ✅ Reusable by anyone, anywhere

---

## 🚀 How to Use

1. **Fork this repository** into your own GitHub account  
2. **Edit `deploy-params.json`** in the repo root with your desired Azure settings  
3. **Run the `prepare-infra.yml` GitHub Action** to set up Azure infra & secrets  
4. **Trigger `deploy-chr.yml` GitHub Action** to deploy your CHR VM on Azure  
5. **Done!** Your CHR is running with no local tools needed 🎉

---

## 📁 Scripts Overview

| Script                         | Description                                                       |
|--------------------------------|-------------------------------------------------------------------|
| `00_Create_Azure_SP_CLI.ps1`   | Creates a Service Principal in Azure using the CLI               |
| `01_Check_Azure_SP_CLI.ps1`    | Verifies that the SP exists and provides Azure Portal link       |
| `02_Set_GitHub_Secret.ps1`     | Creates or updates `AZURE_CREDENTIALS_ADMIN` GitHub secret       |
| `03_Check_GitHub_Secret.ps1`   | Checks if the GitHub secret exists and optionally lists all      |

---

## 🛠 Requirements

- PowerShell 5.1+ or 7+
- [Azure CLI](https://aka.ms/installazurecliwindowsx64)
- [GitHub CLI](https://cli.github.com/)
