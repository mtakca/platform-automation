############################################################
# CORE INFRASTRUCTURE
# ------------------------------------------------------------------------------
# Creates shared infrastructure: vApp, Networks, Firewall
############################################################

############################################################
# DATA SOURCES
############################################################

data "vcd_org" "org" {
  name = var.org_name
}

data "vcd_org_vdc" "vdc" {
  org  = var.org_name
  name = var.vdc_name
}

data "vcd_storage_profile" "storage" {
  org  = var.org_name
  vdc  = var.vdc_name
  name = var.storage_profile
}

############################################################
# VAPP
############################################################
module "vapp" {
  source    = "./modules/vapp"
  providers = { vcd = vcd }

  org_name  = var.org_name
  vdc_name  = var.vdc_name
  vapp_name = "${var.dc_prefix}-${var.environment_name}-${var.app_prefix}-vapp"
}

############################################################
# LOCALS
############################################################
locals {
  # Network naming convention
  network_name_prefix = "${var.dc_prefix}-${var.environment_name}-${var.app_prefix}"
}
