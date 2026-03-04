#########################################
# BASE VM TEMPLATE VARIABLES (GENERIC)
#########################################

variable "vm_role" {
  type        = string
  description = "Role of the VM (e.g., minio, redis, k8s-node)"
}

variable "dc_prefix" {
  type = string
}

variable "app_prefix" {
  type = string
}

variable "environment_name" {
  type        = string
  description = "Environment name (dev/uat/prod)"
}

variable "org_name" {
  type = string
}

variable "vdc_name" {
  type = string
}

variable "vapp_name" {
  type = string
}

variable "catalog_name" {
  type = string
}

variable "template_name" {
  type = string
}

variable "network_name" {
  type = string
}

variable "storage_profile" {
  type = string
}

variable "vapp_template_id" {
  type        = string
  description = "ID of the vApp template (Optional if catalog_name and template_name are provided)"
  default     = ""
}

variable "is_windows" {
  type        = bool
  description = "Set to true for Windows VMs to skip Linux-specific customization"
  default     = false
}



variable "ip_address" {
  type = string
  validation {
    condition     = can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.ip_address))
    error_message = "Must be a valid IPv4 address."
  }
}

variable "ip_allocation_mode" {
  type    = string
  default = "MANUAL"
}

variable "gateway" {
  type = string
}

variable "dns_servers" {
  type    = string
  default = "8.8.8.8,1.1.1.1"
}

variable "name_suffix" {
  type    = string
  default = "01"
}

variable "cpus" {
  type    = number
  default = 4
  validation {
    condition     = var.cpus >= 1
    error_message = "CPUs must be at least 1."
  }
}

variable "memory" {
  type    = number
  default = 8192
  validation {
    condition     = var.memory >= 1024
    error_message = "Memory must be at least 1024 MB."
  }
}

variable "power_on" {
  type    = bool
  default = true
}

variable "data_disks" {
  type = map(object({
    size_gb     = number
    bus_number  = number
    unit_number = number
    mount_path  = optional(string)
  }))
  default = {}
}

variable "auto_mount_disks" {
  description = "Enable automatic disk mounting service"
  type        = bool
  default     = false
}

variable "root_disk_size_gb" {
  type        = number
  description = "Size of the root disk in GB"
  default     = 64
}

variable "root_password" {
  type      = string
  sensitive = true
}

variable "default_user" {
  type    = string
  default = "example_user"
}

variable "default_password" {
  type      = string
  sensitive = true
}

variable "users" {
  description = "List of users to create (SSH key auth only, sudo enabled)"
  type = list(object({
    username = string
    ssh_key  = string
  }))
  default = []
}

variable "allow_root_ssh" {
  type    = bool
  default = false
}

variable "harden" {
  type    = bool
  default = true
}

variable "audit_enable" {
  type    = bool
  default = true
}

variable "install_cloudinit" {
  type    = bool
  default = true
}

variable "custom_metadata" {
  type    = map(string)
  default = {}
}
