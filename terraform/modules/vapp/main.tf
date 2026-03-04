############################################################
# VAPP MODULE (vCD 3.14.1, GENERIC)
############################################################

terraform {
  required_providers {
    vcd = {
      source  = "vmware/vcd"
      version = "3.14.1"
    }
  }
}

resource "vcd_vapp" "this" {
  name     = var.vapp_name
  org      = var.org_name
  vdc      = var.vdc_name
  power_on = var.power_on

  metadata_entry {
    key         = "environment"
    value       = "terraform-managed"
    type        = "MetadataStringValue"
    user_access = "READWRITE"
    is_system   = false
  }
}

resource "vcd_vapp_org_network" "attach" {
  for_each = toset(var.org_network_names)

  org                    = var.org_name
  vdc                    = var.vdc_name
  vapp_name              = vcd_vapp.this.name
  org_network_name       = each.value
  is_fenced              = false
  retain_ip_mac_enabled  = false
  reboot_vapp_on_removal = true
}