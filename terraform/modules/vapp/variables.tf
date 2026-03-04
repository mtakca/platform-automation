variable "org_name" {
  description = "vCloud organization name"
  type        = string
}

variable "vdc_name" {
  description = "Virtual Data Center name"
  type        = string
}

variable "vapp_name" {
  description = "Name of the vApp to create"
  type        = string
}

variable "power_on" {
  description = "Whether to power on the vApp after creation"
  type        = bool
  default     = true
}

variable "org_network_names" {
  description = "List of Org networks to attach to vApp"
  type        = list(string)
  default     = []
}