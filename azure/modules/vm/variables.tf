variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  type        = string
  default     = ""
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
  default     = ""
}

variable "enable_vm_availability_set" {
  description = "Manages an Availability Set for Virtual Machines."
  type        = bool
  default     = false
}

variable "enable_proximity_placement_group" {
  description = "Manages a proximity placement group for virtual machines, virtual machine scale sets and availability sets."
  type        = bool
  default     = false
}

variable "virtual_machine_name" {
  description = "The name of the virtual machine."
  type        = string
  default     = ""
}

variable "instances_count" {
  description = "The number of Virtual Machines required."
  type        = number
  default     = 1
}

variable "os_flavor" {
  description = "Specify the flavor of the operating system image to deploy Virtual Machine. Valid values are `windows` and `linux`"
  type        = string
  default     = "windows"
}

variable "virtual_machine_size" {
  description = "The Virtual Machine SKU for the Virtual Machine, Default is Standard_A2_V2"
  type        = string
  default     = "Standard_A2_v2"
}

variable "disable_password_authentication" {
  description = "Should Password Authentication be disabled on this Virtual Machine? Defaults to true."
  type        = bool
  default     = true
}

variable "admin_username" {
  description = "The username of the local administrator used for the Virtual Machine."
  type        = string
}

variable "admin_password" {
  description = "The Password which should be used for the local-administrator on this Virtual Machine"
  type        = string
  default     = null
}

variable "source_image_id" {
  description = "The ID of an Image which each Virtual Machine should be based on"
  type        = string
  default     = null
}

variable "dedicated_host_id" {
  description = "The ID of a Dedicated Host where this machine should be run on."
  type        = string
  default     = null
}

variable "custom_data" {
  description = "Base64 encoded file of a bash script that gets run once by cloud-init upon VM creation"
  type        = string
  default     = null
}

variable "enable_automatic_updates" {
  description = "Specifies if Automatic Updates are Enabled for the Windows Virtual Machine."
  type        = bool
  default     = true
}

variable "enable_encryption_at_host" {
  description = " Should all of the disks (including the temp disk) attached to this Virtual Machine be encrypted by enabling Encryption at Host?"
  type        = bool
  default     = false
}

variable "vm_availability_zone" {
  description = "The Zone in which this Virtual Machine should be created. Conflicts with availability set and shouldn't use both"
  type        = string
  default     = null
}

variable "patch_mode" {
  description = "Specifies the mode of in-guest patching to this Windows Virtual Machine. Possible values are `Manual`, `AutomaticByOS` and `AutomaticByPlatform`"
  type        = string
  default     = "AutomaticByOS"
}

variable "license_type" {
  description = "Specifies the type of on-premise license which should be used for this Virtual Machine. Possible values are None, Windows_Client and Windows_Server."
  type        = string
  default     = "None"
}

variable "vm_time_zone" {
  description = "Specifies the Time Zone which should be used by the Virtual Machine"
  type        = string
  default     = null
}

variable "generate_admin_ssh_key" {
  description = "Generates a secure private key and encodes it as PEM."
  type        = bool
  default     = false
}

variable "admin_ssh_key_data" {
  description = "specify the path to the existing SSH key to authenticate Linux virtual machine"
  type        = string
  default     = null
}

variable "algorithm" {
  description = "Name of the algorithm to use when generating the private key. Currently-supported values are: RSA, ECDSA, ED25519"
  type        = string
  default     = "RSA"
}
variable "rsa_bits" {
  description = "When algorithm is RSA, the size of the generated RSA key, in bits (default: 2048)"
  type        = number
  default     = 4096
}

variable "custom_image" {
  description = "Provide the custom image to this module if the default variants are not sufficient"
  type = list(object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  }))
  default = null
}


variable "os_disk_storage_account_type" {
  description = "The Type of Storage Account which should back this the Internal OS Disk. Possible values include Standard_LRS, StandardSSD_LRS and Premium_LRS."
  default     = "StandardSSD_LRS"
}

variable "os_disk_caching" {
  description = "The Type of Caching which should be used for the Internal OS Disk. Possible values are `None`, `ReadOnly` and `ReadWrite`"
  default     = "ReadWrite"
}

variable "disk_encryption_set_id" {
  description = "The ID of the Disk Encryption Set which should be used to Encrypt this OS Disk. The Disk Encryption Set must have the `Reader` Role Assignment scoped on the Key Vault - in addition to an Access Policy to the Key Vault"
  default     = null
}

variable "disk_size_gb" {
  description = "The Size of the Internal OS Disk in GB, if you wish to vary from the size used in the image this Virtual Machine is sourced from."
  default     = null
}

variable "enable_os_disk_write_accelerator" {
  description = "Should Write Accelerator be Enabled for this OS Disk? This requires that the `storage_account_type` is set to `Premium_LRS` and that `caching` is set to `None`."
  default     = false
}

variable "os_disk_name" {
  description = "The name which should be used for the Internal OS Disk"
  default     = null
}

variable "identity" {
  description = "Managed Identity which should be assigned the virtual machine."
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = null
}

variable "enable_boot_diagnostics" {
  description = "Should the boot diagnostics enabled?"
  type        = bool
  default     = false
}

variable "data_disks" {
  description = "Managed Data Disks for azure viratual machine"
  type = list(object({
    name                 = string
    storage_account_type = string
    disk_size_gb         = number
  }))
  default = []
}

variable "log_analytics_workspace_id" {
  description = "The name of log analytics workspace resource id"
  type        = string
  default     = null
}

variable "log_analytics_customer_id" {
  description = "The Workspace (or Customer) ID for the Log Analytics Workspace."
  type        = string
  default     = null
}

variable "log_analytics_workspace_primary_shared_key" {
  description = "The Primary shared key for the Log Analytics Workspace"
  type        = string
  default     = null
}

variable "deploy_log_analytics_agent" {
  description = "Install log analytics agent to windows or linux VM"
  type        = bool
  default     = false
}

variable "random_password_length" {
  description = "The desired length of random password created by this module"
  type        = number
  default     = 24
}
