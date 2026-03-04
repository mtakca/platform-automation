############################################################
# CORE INFRASTRUCTURE NETWORKS
# Network Architecture 2026:
#   10.0.X.Xx - Core-Infra (HAProxy LB, OPNsense)
#   10.0.X.Xx - Management (AD, Admin)
############################################################

# Core Infra Network (HAProxy LB, Network Services)
resource "vcd_network_isolated" "core_infra" {
  name = "${var.dc_prefix}-${var.environment_name}-${var.app_prefix}-core-infra-vnet"

  org = var.org_name
  vdc = var.vdc_name

  gateway    = "10.0.X.X"
  dns1       = "8.8.8.8"
  dns2       = "8.8.8.8"
  dns_suffix = "example.com"

  static_ip_pool {
    start_address = "10.0.X.X"
    end_address   = "10.0.X.X"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Management Network (AD, Admin Access)
resource "vcd_network_isolated" "management" {
  name = "${var.dc_prefix}-${var.environment_name}-${var.app_prefix}-management-vnet"

  org = var.org_name
  vdc = var.vdc_name

  gateway    = "10.0.X.X"
  dns1       = "8.8.8.8"
  dns2       = "8.8.8.8"
  dns_suffix = "example.com"

  static_ip_pool {
    start_address = "10.0.X.X"
    end_address   = "10.0.X.X"
  }

  lifecycle {
    prevent_destroy = true
  }
}

############################################################
# ATTACH ISOLATED NETWORKS TO VAPP
############################################################

resource "vcd_vapp_org_network" "core_infra" {
  org              = var.org_name
  vdc              = var.vdc_name
  vapp_name        = module.vapp.vapp_name
  org_network_name = vcd_network_isolated.core_infra.name

  depends_on = [module.vapp]
}

resource "vcd_vapp_org_network" "management" {
  org              = var.org_name
  vdc              = var.vdc_name
  vapp_name        = module.vapp.vapp_name
  org_network_name = vcd_network_isolated.management.name

  depends_on = [module.vapp]
}

############################################################
# NETWORK OUTPUTS FOR OPNSENSE
############################################################

output "core_networks" {
  description = "Core networks for firewall interface attachment"
  value = {
    core_infra = {
      name       = vcd_network_isolated.core_infra.name
      id         = vcd_network_isolated.core_infra.id
      gateway_ip = vcd_network_isolated.core_infra.gateway
      nic_order  = 1  # vmx1 - Core-Infra
    }
    management = {
      name       = vcd_network_isolated.management.name
      id         = vcd_network_isolated.management.id
      gateway_ip = vcd_network_isolated.management.gateway
      nic_order  = 2  # vmx2 - Management
    }
  }
}