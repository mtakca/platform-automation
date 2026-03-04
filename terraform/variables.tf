################################################################################
# CORE INFRASTRUCTURE - VARIABLES
# ------------------------------------------------------------------------------
# Core infrastructure: Networks, Firewall, Shared Resources
################################################################################

############################################################
# PROVIDER + BASE CONFIG
############################################################

variable "vcd_url" {
  description = "VCD API URL"
  type        = string
}

variable "vcd_access_token" {
  description = "Access token for VCD (Passed automatically by Makefile)"
  type        = string
  sensitive   = true
}

variable "org_name" {
  description = "VCD Organization name"
  type        = string
}

variable "vdc_name" {
  description = "VCD Virtual Data Center name"
  type        = string
}

variable "catalog_name" {
  description = "VCD Catalog name for templates and ISOs"
  type        = string
}

variable "storage_profile" {
  description = "Storage profile to use for VMs"
  type        = string
}

variable "gateway" {
  description = "Gateway IP for external network"
  type        = string
}

############################################################
# NAMING
############################################################

variable "dc_prefix" {
  description = "Datacenter prefix for naming"
  type        = string
}

variable "environment_name" {
  description = "Environment name (dev, uat, prod)"
  type        = string
}

variable "app_prefix" {
  description = "Application prefix for naming"
  type        = string
  default     = "core"
}

############################################################
# NETWORK CONFIGURATION
############################################################

variable "networks" {
  description = "Map of isolated networks to create"
  type = map(object({
    gateway       = string
    dns1          = optional(string)
    dns2          = optional(string)
    pool_start    = string
    pool_end      = string
  }))
  default = {
    app = {
      gateway    = "10.0.X.X"
      dns1       = "10.0.X.X"
      dns2       = "10.0.X.X"
      pool_start = "10.0.X.X"
      pool_end   = "10.0.X.X"
    }
    data = {
      gateway    = "10.0.X.X"
      dns1       = "10.0.X.X"
      dns2       = "10.0.X.X"
      pool_start = "10.0.X.X"
      pool_end   = "10.0.X.X"
    }
    kafka = {
      gateway    = "10.0.X.X"
      dns1       = "10.0.X.X"
      dns2       = "10.0.X.X"
      pool_start = "10.0.X.X"
      pool_end   = "10.0.X.X"
    }
  }
}

############################################################
# FIREWALL CONFIGURATION
############################################################

variable "firewall_enabled" {
  description = "Enable OPNsense internal firewall deployment"
  type        = bool
  default     = true
}

variable "firewall_vpn_enabled" {
  description = "Enable OPNsense VPN firewall deployment"
  type        = bool
  default     = false
}

variable "firewall_iso_name" {
  description = "OPNsense ISO name in catalog"
  type        = string
  default     = "OPNsense-25.7-dvd-amd64.iso"
}

variable "firewall_iso_catalog" {
  description = "Catalog containing OPNsense ISO"
  type        = string
  default     = "EXAMPLE"
}

variable "firewall_cpus" {
  description = "Number of CPUs for firewall VM"
  type        = number
  default     = 2
}

variable "firewall_memory" {
  description = "Memory in MB for firewall VM"
  type        = number
  default     = 4096
}

variable "firewall_disk_size" {
  description = "OS disk size in MB for firewall VM"
  type        = number
  default     = 32768
}

variable "firewall_wan_network" {
  description = "WAN network name (external)"
  type        = string
}

variable "firewall_wan_ip" {
  description = "WAN IP address for firewall"
  type        = string
}

variable "firewall_interfaces" {
  description = "Map of firewall interfaces to internal networks"
  type = map(object({
    network_key = string
    ip          = string
    is_gateway  = optional(bool, true)
  }))
  default = {
    lan = {
      network_key = "app"
      ip          = "10.0.X.X"
    }
    opt1 = {
      network_key = "data"
      ip          = "10.0.X.X"
    }
    opt2 = {
      network_key = "kafka"
      ip          = "10.0.X.X"
    }
  }
}

variable "firewall_vpn_external_network" {
  description = "VPN firewall external network name"
  type        = string
  default     = ""
}

variable "firewall_vpn_external_ip" {
  description = "VPN firewall external interface IP address"
  type        = string
  default     = ""
}

variable "firewall_vpn_internal_network" {
  description = "VPN firewall internal network name"
  type        = string
  default     = ""
}

variable "firewall_vpn_internal_ip" {
  description = "VPN firewall internal interface IP address"
  type        = string
  default     = ""
}

############################################################
# EXTERNAL FIREWALL CONFIGURATION
############################################################

variable "firewall_ext_enabled" {
  description = "Enable external firewall deployment"
  type        = bool
  default     = false
}

variable "firewall_ext_external_network" {
  description = "External firewall - external network name"
  type        = string
  default     = ""
}

variable "firewall_ext_external_ip" {
  description = "External firewall - external interface IP address"
  type        = string
  default     = ""
}

variable "firewall_ext_internal_network" {
  description = "External firewall - internal network name"
  type        = string
  default     = ""
}

variable "firewall_ext_internal_ip" {
  description = "External firewall - internal interface IP address"
  type        = string
  default     = ""
}

############################################################
# OPNSENSE PROVIDER CONFIGURATION
############################################################

variable "opnsense_ip" {
  description = "OPNsense management IP address"
  type        = string
  default     = ""
}

variable "opnsense_api_key" {
  description = "OPNsense API key (generate via System > Access > Users)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "opnsense_api_secret" {
  description = "OPNsense API secret"
  type        = string
  sensitive   = true
  default     = ""
}

############################################################
# VAPP NETWORK INTEGRATION
# Enable/disable reading networks from each vApp's remote state
############################################################

variable "vapp_wallet_enabled" {
  description = "Include wallet vApp networks in firewall"
  type        = bool
  default     = true
}

variable "vapp_idm_enabled" {
  description = "Include IDM vApp networks in firewall"
  type        = bool
  default     = false
}

variable "vapp_monitoring_enabled" {
  description = "Include monitoring vApp networks in firewall"
  type        = bool
  default     = false
}

variable "vapp_security_enabled" {
  description = "Include security vApp networks in firewall"
  type        = bool
  default     = false
}

variable "vapp_access_enabled" {
  description = "Include access vApp networks in firewall"
  type        = bool
  default     = false
}

variable "vapp_devops_enabled" {
  description = "Include DevOps vApp networks in firewall"
  type        = bool
  default     = false
}

variable "vapp_tenant_b_enabled" {
  description = "Include TenantB vApp networks in firewall"
  type        = bool
  default     = false
}

variable "vapp_myapp_enabled" {
  description = "Include Myapp vApp networks in firewall"
  type        = bool
  default     = false
}

variable "vapp_pf_enabled" {
  description = "Include PF vApp networks in firewall"
  type        = bool
  default     = false
}

variable "vapp_h3m_enabled" {
  description = "Include H3M vApp networks in firewall"
  type        = bool
  default     = false
}

variable "vapp_hsm_enabled" {
  description = "Include HSM vApp networks in firewall"
  type        = bool
  default     = false
}

variable "vapp_tenant_c_enabled" {
  description = "Include TenantC vApp networks in firewall"
  type        = bool
  default     = false
}

variable "vapp_tenant_d_enabled" {
  description = "Include TenantD vApp networks in firewall"
  type        = bool
  default     = false
}

############################################################
# VM DEPLOYMENT (HAProxy, etc.)
############################################################

variable "template_name" {
  type        = string
  default     = "ubuntu-24.04-x86_64"
}

variable "node_pools" {
  description = "Map of node pools to deploy. Each pool defines a role, count, and resources."
  type = map(object({
    role              = string
    count             = number
    ip_start_offset   = number
    cpus              = optional(number, 4)
    memory            = optional(number, 8192)
    template_name     = optional(string)
    catalog_name      = optional(string)
    is_windows        = optional(bool, false)
    network_name      = optional(string)
    network_cidr      = optional(string)

    data_disks        = optional(map(object({
      size_gb     = number
      bus_number  = number
      unit_number = number
      mount_path  = optional(string)
    })), {})
    auto_mount_disks  = optional(bool, false)
    harden            = optional(bool, true)
    audit_enable      = optional(bool, true)
    allow_root_ssh    = optional(bool, false)
    install_cloudinit = optional(bool, true)
    custom_metadata   = optional(map(string), {})
  }))
  default = {}
}

variable "service_config" {
  description = "Service-specific configuration for HA (VIPs, keepalived)"
  type = map(object({
    vip           = optional(string, "")
    vrid          = optional(number, 0)
    check_script  = optional(string, "")
    priorities    = optional(map(number), {})
  }))
  default = {}
}

variable "dns_servers" {
  description = "List of DNS servers"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.8.8"]
}

variable "default_password" {
  type      = string
  sensitive = true
  default   = "DefaultPassword123!"
}

variable "root_password" {
  type      = string
  sensitive = true
  default   = "DefaultPassword123!"
}

variable "users" {
  description = "List of users to create (SSH key auth only, sudo enabled)"
  type = list(object({
    username = string
    ssh_key  = string
  }))
  default = []
}

variable "ansible_user" {
  description = "User for Ansible connection"
  type        = string
  default     = "example_user"
}