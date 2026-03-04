############################################################
# BASE INFRA MODULE (GENERIC, vCD 3.14.1)
# Reads shared resources: ORG, VDC, CATALOG, TEMPLATE, NETWORK
############################################################

terraform {
  required_providers {
    vcd = {
      source  = "vmware/vcd"
      version = "3.14.1"
    }
  }
}

############################################################
# ORGANIZATION
############################################################
data "vcd_org" "this" {
  name = var.org_name
}

############################################################
# VDC
############################################################
data "vcd_org_vdc" "this" {
  org  = var.org_name
  name = var.ovdc_name
}

############################################################
# CATALOG
############################################################
data "vcd_catalog" "this" {
  org  = var.org_name
  name = var.catalog_name
}

############################################################
# TEMPLATE (VAPP TEMPLATE)
############################################################

data "vcd_catalog_vapp_template" "ubuntu_image" {
  org        = var.org_name
  catalog_id = data.vcd_catalog.this.id
  name       = var.template_name
}