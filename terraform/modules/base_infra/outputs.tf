############################################################
# BASE INFRA OUTPUTS
############################################################

output "org_name" {
  description = "Resolved Org name"
  value       = data.vcd_org.this.name
}

output "vdc_name" {
  description = "Resolved VDC name"
  value       = data.vcd_org_vdc.this.name
}

output "catalog_name" {
  description = "Resolved Catalog name"
  value       = data.vcd_catalog.this.name
}


output "template_name" {
  description = "Template name to pass into VM module"
  value       = var.template_name
}

output "storage_profile" {
  description = "Storage profile for VM disks"
  value       = var.storage_profile
}


output "gateway" {
  description = "Network gateway"
  value       = var.gateway
}

output "vapp_template_id" {
  description = "ID of the vApp template"
  value       = data.vcd_catalog_vapp_template.ubuntu_image.id
}