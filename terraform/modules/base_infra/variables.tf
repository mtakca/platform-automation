############################################################
# BASE INFRA VARIABLES
############################################################

variable "vcd_url" {
  description = "vCloud Director API endpoint"
  type        = string
}

variable "org_name" {
  description = "Organization name"
  type        = string
}

variable "ovdc_name" {
  description = "Org VDC Name"
  type        = string
}

variable "catalog_name" {
  description = "Catalog name where template resides"
  type        = string
}

variable "template_name" {
  description = "vApp template name to deploy"
  type        = string
}


variable "gateway" {
  description = "Default gateway IP"
  type        = string
}

variable "storage_profile" {
  description = "vCD storage profile"
  type        = string
}
