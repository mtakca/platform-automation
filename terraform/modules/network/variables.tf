variable "environment" {
  description = "Deployment environment (e.g. dev, prod, uat)"
  type        = string
}

variable "dc_prefix" {
  description = "Datacenter prefix (e.g. 34)"
  type        = string
}

variable "app_prefix" {
  description = "Application prefix (e.g. myapp)"
  type        = string
}



variable "org_name" {
  description = "Organization name"
  type        = string
}

variable "vdc_name" {
  description = "Virtual Data Center name"
  type        = string
}

variable "subnets" {
  description = "Map of subnets to create or import. For type='org', 'name' must match the existing network name."
  type = map(object({
    cidr        = optional(string) # Required for routed/isolated, optional for org
    type        = string           # routed, isolated, or org
    name        = optional(string) # Override generated name or existing network name
    gateway     = optional(string)
    dns_suffix  = optional(string)
    suffix      = optional(string)
    description = optional(string)
    net_type    = optional(string) # routed (default) or direct (for VLAN/External)
  }))
}



variable "dns_servers" {
  description = "List of DNS servers"
  type        = list(string)
  default     = ["1.1.1.1", "8.8.8.8"] # Default public, override with internal
}
