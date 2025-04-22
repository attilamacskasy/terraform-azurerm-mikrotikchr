# 🛰️ Rover Visualization Stack (for MikroTik CHR Terraform Plans)

This subproject enables visual inspection of planned infrastructure changes for the [terraform-azurerm-mikrotikchr](https://github.com/attilamacskasy/terraform-azurerm-mikrotikchr) repository.

It uses [Rover](https://github.com/im2nguyen/rover), a browser-based Terraform visualizer, deployed via Portainer on a Synology NAS using Docker Compose.

---

## 🧭 Why Use Rover in This Project?

This repository provisions MikroTik CHR virtual appliances in Azure using Terraform. Before applying changes, it’s crucial to **review the Terraform plan** to verify what will be created, changed, or destroyed — especially for cloud-based network appliances.

Rover provides an **interactive visual interface** to inspect the plan, which is easier and safer than reviewing raw JSON or CLI output.

By running Rover on your local Synology NAS using Portainer, you can:

- Easily visualize complex network resources before deployment
- Catch mistakes or unintended changes visually
- Avoid applying incorrect infrastructure to production or demo environments

---

## 🧰 Tech Stack

- **Terraform** – Used for deploying MikroTik CHR in Azure.
- **GitHub Actions** – Automates Terraform plan/apply/destroy workflows.
- **Rover** – Visualizes the JSON output of `terraform show`.
- **Portainer** – Manages Docker stacks on Synology for consistent deployments.
- **Synology NAS** – Hosts Docker and provides shared volume access to plan artifacts.

---

## 📦 Why Use a Synology Shared Volume?

Synology’s shared volume `/volume1/rover` is:

- Easy to mount into containers
- Persistent and system-wide
- Accessible from both the host and Docker

By exporting `plan.json` from CI or manually copying it to this path, you enable Rover to instantly pick it up without copying files into the container.

---

## 🚀 Why Use Portainer Instead of Synology’s Docker UI?

| Feature                      | Synology Docker UI | Portainer |
|-----------------------------|--------------------|-----------|
| Docker Compose / Stacks     | ❌ Not supported    | ✅ Full support |
| Reusable config definitions | ❌ Manual-only      | ✅ Re-deployable stacks |
| Volume & network control    | 🚫 Limited          | ✅ Advanced |
| GitOps & CI/CD friendly     | ❌                 | ✅ |
| Visual management           | ✅ Basic            | ✅ Excellent |

**Portainer stacks** allow you to:

- Reuse version-controlled `docker-compose.yml` definitions
- Easily redeploy with updated configs
- Maintain parity between dev and production

