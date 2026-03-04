terraform {
  required_providers {
    vcd = {
      source  = "vmware/vcd"
      version = ">= 3.8.0"
    }
  }
}

# -------------------------------------------------------------------------
# DATA SOURCES
# -------------------------------------------------------------------------
data "vcd_org_vdc" "nsxt" {
  org  = var.org_name
  name = var.vdc_name
}

# Import existing networks (Brownfield / VLANs provided by Network Team)
# Import existing routed networks (default)
data "vcd_network_routed" "org" {
  for_each = {
    for k, v in var.subnets : k => v
    if v.type == "org" && try(v.net_type, "routed") == "routed"
  }

  org  = var.org_name
  vdc  = var.vdc_name
  name = local.network_names[each.key]
}

# Import existing direct networks (VLANs / External)
data "vcd_network_direct" "org_direct" {
  for_each = {
    for k, v in var.subnets : k => v
    if v.type == "org" && try(v.net_type, "routed") == "direct"
  }

  org  = var.org_name
  vdc  = var.vdc_name
  name = local.network_names[each.key]
}

# -------------------------------------------------------------------------
# LOCALS
# -------------------------------------------------------------------------
locals {
  network_names = {
    for k, v in var.subnets : k => (
      v.name != null ? v.name : "${var.dc_prefix}-${var.environment}-${var.app_prefix}-${k}-net${v.suffix != null ? "-${v.suffix}" : ""}"
    )
  }

  # Smart DNS: Only use public DNS for routed networks. Isolated gets empty or internal if provided.
  # Assuming var.dns_servers contains public DNS by default.
  default_dns1 = length(var.dns_servers) > 0 ? var.dns_servers[0] : null
  default_dns2 = length(var.dns_servers) > 1 ? var.dns_servers[1] : null
}

# -------------------------------------------------------------------------
# RESOURCES: NETWORKS
# -------------------------------------------------------------------------

# 1. Routed Networks (Greenfield) - REMOVED
# User Strategy: All routed networks are provided by Network Team (Brownfield).
# Terraform only imports them via data source above.

# 2. Isolated Networks (Greenfield - No Internet)
resource "vcd_network_isolated" "isolated" {
  for_each = { for k, v in var.subnets : k => v if v.type == "isolated" }

  org     = var.org_name
  vdc     = var.vdc_name
  name    = local.network_names[each.key]
  gateway = each.value.gateway != null ? each.value.gateway : cidrhost(each.value.cidr, 1)

  static_ip_pool {
    start_address = cidrhost(each.value.cidr, 10)
    end_address   = cidrhost(each.value.cidr, 100)
  }

  # Security: Isolated networks should NOT use Public DNS by default to avoid timeouts/noise
  # Only assign if explicitly needed, otherwise leave empty
  dns1 = null 
  dns2 = null
  dns_suffix = each.value.dns_suffix

  description = each.value.description
}

# -------------------------------------------------------------------------
# RESOURCES: SECURITY (NSX-T FIREWALL)
# -------------------------------------------------------------------------
# PHASE 1 DECISION: Firewall rules are managed MANUALLY by the Network Team.
# Terraform should NOT touch the firewall configuration to avoid conflicts.
# resource "vcd_nsxt_firewall" "main" { ... }
