# MikroTik CHR Deployment on Azure

This Terraform configuration deploys a MikroTik Cloud Hosted Router (CHR) on Microsoft Azure. It includes all necessary Azure resources such as storage accounts, virtual machines, and networking components.

## Disclaimer - Work in Progress

This is an initial version based on a previously working prototype, but it is not yet finalized. Further improvements and adjustments are needed before it can be considered a stable release.

### Pending Improvements:
- **Lab Documentation**: Proper documentation is still to be added, including a diagram. Currently experimenting with diagram-as-code using Mermaid for GitHub Flavored Markdown.
- **MikroTik Configuration Scripts**: The RSC scripts need cleanup and refinement.
- **Security**: Passwords within Terraform files are not ideal. These should be replaced with secure mechanisms, such as Azure Key Vault in the Landing Zone (LZ).
- **Code Quality**: The code is not yet clean and requires further refinement.
- **README.md**: A more comprehensive and polished version of this README is still to be created.

## Acknowledgements

A special thanks to [Hugo Rodrigues](https://www.linkedin.com/in/hmsrodrigues/) for his valuable contribution to the initial version of this Terraform configuration. Hugo's input and expertise helped make this project possible.

Thank you for your support!

## Resources Provisioned

### 1. **Storage Resources**
- **Storage Account**: Stores the MikroTik CHR VHD file.
- **Storage Container**: Holds the blob for the MikroTik CHR image.
- **Storage Blob**: Uploads the MikroTik CHR VHD file.

### 2. **Image and Virtual Machine**
- **Azure Image**: Creates an Azure-managed image from the MikroTik VHD blob.
- **Virtual Machine**: Deploys a VM using the custom image, with the following specifications:
  - Size: `Standard_B1s`
  - Admin User: `cloudadmin`
  - Disk Type: Standard SSD

### 3. **Networking**
- **Network Interface**: Creates a NIC for the VM with dynamic private IP allocation.
- **Route Table**: Adds a custom route for traffic destined to a VMware lab subnet (`172.22.22.0/24`).
- **Subnet Route Table Association**: Associates the route table with the specified subnet.

## Configuration Variables

| Variable           | Description                          |
|---------------------|--------------------------------------|
| `project`           | Project name for resource naming.   |
| `environment`       | Environment (e.g., dev, prod).      |
| `az_region`         | Azure region for resources.         |
| `resource_group`    | Name of the Azure resource group.   |
| `location`          | Azure location for resources.       |
| `az_subnet_id`      | Subnet ID for the VM's NIC.         |

## How to Use

### Prerequisites
- Terraform installed on your local machine.
- Azure CLI authenticated with appropriate permissions.
- MikroTik CHR VHD file (`chr-7.10rc6.vhd`) stored locally and accessible by the configuration.


