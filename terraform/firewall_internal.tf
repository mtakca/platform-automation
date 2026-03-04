############################################################
# OPNSENSE FIREWALL VM
############################################################

# Read wallet module state to get network information
data "terraform_remote_state" "wallet" {
  count   = var.firewall_enabled && var.vapp_wallet_enabled ? 1 : 0
  backend = "s3"

  config = {
    bucket = "example_tenant-example_user-tr-uat-tf-state"
    key    = "env:/${var.environment_name}-wallet/infra/${var.environment_name}/wallet/terraform.tfstate"
    region = "eu-central-1"
  }

  defaults = {
    networks = {}
  }
}

# Read IDM module state to get network information
data "terraform_remote_state" "idm" {
  count   = var.firewall_enabled && var.vapp_idm_enabled ? 1 : 0
  backend = "s3"

  config = {
    bucket = "example_tenant-example_user-tr-uat-tf-state"
    key    = "env:/${var.environment_name}-idm/infra/${var.environment_name}/idm/terraform.tfstate"
    region = "eu-central-1"
  }

  defaults = {
    networks = {}
  }
}

# Read Monitoring module state to get network information
data "terraform_remote_state" "monitoring" {
  count   = var.firewall_enabled && var.vapp_monitoring_enabled ? 1 : 0
  backend = "s3"

  config = {
    bucket = "example_tenant-example_user-tr-uat-tf-state"
    key    = "env:/${var.environment_name}-monitoring/infra/${var.environment_name}/monitoring/terraform.tfstate"
    region = "eu-central-1"
  }

  defaults = {
    networks = {}
  }
}

# Read Security module state to get network information
data "terraform_remote_state" "security" {
  count   = var.firewall_enabled && var.vapp_security_enabled ? 1 : 0
  backend = "s3"

  config = {
    bucket = "example_tenant-example_user-tr-uat-tf-state"
    key    = "env:/uat-security/infra/uat/security/terraform.tfstate"
    region = "eu-central-1"
  }

  defaults = {
    networks = {}
  }
}

# Read Access module state to get network information
data "terraform_remote_state" "access" {
  count   = var.firewall_enabled && var.vapp_access_enabled ? 1 : 0
  backend = "s3"

  config = {
    bucket = "example_tenant-example_user-tr-uat-tf-state"
    key    = "env:/${var.environment_name}-access/infra/${var.environment_name}/access/terraform.tfstate"
    region = "eu-central-1"
  }

  defaults = {
    networks = {}
  }
}

# Read DevOps module state to get network information
data "terraform_remote_state" "devops" {
  count   = var.firewall_enabled && var.vapp_devops_enabled ? 1 : 0
  backend = "s3"

  config = {
    bucket = "example_tenant-example_user-tr-uat-tf-state"
    key    = "env:/${var.environment_name}-devops/infra/${var.environment_name}/devops/terraform.tfstate"
    region = "eu-central-1"
  }

  defaults = {
    networks = {}
  }
}

# Read TenantB module state
data "terraform_remote_state" "tenant_b" {
  count   = var.firewall_enabled && var.vapp_tenant_b_enabled ? 1 : 0
  backend = "s3"

  config = {
    bucket = "example_tenant-example_user-tr-uat-tf-state"
    key    = "env:/${var.environment_name}-tenant_b/infra/${var.environment_name}/tenant_b/terraform.tfstate"
    region = "eu-central-1"
  }

  defaults = {
    networks = {}
  }
}

# Read Myapp module state
data "terraform_remote_state" "myapp" {
  count   = var.firewall_enabled && var.vapp_myapp_enabled ? 1 : 0
  backend = "s3"

  config = {
    bucket = "example_tenant-example_user-tr-uat-tf-state"
    key    = "env:/${var.environment_name}-myapp/infra/${var.environment_name}/myapp/terraform.tfstate"
    region = "eu-central-1"
  }

  defaults = {
    networks = {}
  }
}

# Read PF module state
data "terraform_remote_state" "pf" {
  count   = var.firewall_enabled && var.vapp_pf_enabled ? 1 : 0
  backend = "s3"

  config = {
    bucket = "example_tenant-example_user-tr-uat-tf-state"
    key    = "env:/${var.environment_name}-pf/infra/${var.environment_name}/pf/terraform.tfstate"
    region = "eu-central-1"
  }

  defaults = {
    networks = {}
  }
}

# Read H3M module state
data "terraform_remote_state" "h3m" {
  count   = var.firewall_enabled && var.vapp_h3m_enabled ? 1 : 0
  backend = "s3"

  config = {
    bucket = "example_tenant-example_user-tr-uat-tf-state"
    key    = "env:/${var.environment_name}-h3m/infra/${var.environment_name}/h3m/terraform.tfstate"
    region = "eu-central-1"
  }

  defaults = {
    networks = {}
  }
}

# Read HSM module state
data "terraform_remote_state" "hsm" {
  count   = var.firewall_enabled && var.vapp_hsm_enabled ? 1 : 0
  backend = "s3"

  config = {
    bucket = "example_tenant-example_user-tr-uat-tf-state"
    key    = "env:/${var.environment_name}-hsm/infra/${var.environment_name}/hsm/terraform.tfstate"
    region = "eu-central-1"
  }

  defaults = {
    networks = {}
  }
}

# Read TenantC module state
data "terraform_remote_state" "tenant_c" {
  count   = var.firewall_enabled && var.vapp_tenant_c_enabled ? 1 : 0
  backend = "s3"

  config = {
    bucket = "example_tenant-example_user-tr-uat-tf-state"
    key    = "env:/${var.environment_name}-tenant_c/infra/${var.environment_name}/tenant_c/terraform.tfstate"
    region = "eu-central-1"
  }

  defaults = {
    networks = {}
  }
}

# Read TenantD module state
data "terraform_remote_state" "tenant_d" {
  count   = var.firewall_enabled && var.vapp_tenant_d_enabled ? 1 : 0
  backend = "s3"

  config = {
    bucket = "example_tenant-example_user-tr-uat-tf-state"
    key    = "env:/${var.environment_name}-tenant_d/infra/${var.environment_name}/tenant_d/terraform.tfstate"
    region = "eu-central-1"
  }

  defaults = {
    networks = {}
  }
}

locals {
  # Get networks from all remote states (only if enabled)
  wallet_networks     = var.firewall_enabled && var.vapp_wallet_enabled ? try(data.terraform_remote_state.wallet[0].outputs.networks, {}) : {}
  idm_networks        = var.firewall_enabled && var.vapp_idm_enabled ? try(data.terraform_remote_state.idm[0].outputs.networks, {}) : {}
  monitoring_networks = var.firewall_enabled && var.vapp_monitoring_enabled ? try(data.terraform_remote_state.monitoring[0].outputs.networks, {}) : {}
  security_networks   = var.firewall_enabled && var.vapp_security_enabled ? try(data.terraform_remote_state.security[0].outputs.networks, {}) : {}
  access_networks     = var.firewall_enabled && var.vapp_access_enabled ? try(data.terraform_remote_state.access[0].outputs.networks, {}) : {}
  devops_networks     = var.firewall_enabled && var.vapp_devops_enabled ? try(data.terraform_remote_state.devops[0].outputs.networks, {}) : {}
  tenant_b_networks    = var.firewall_enabled && var.vapp_tenant_b_enabled ? try(data.terraform_remote_state.tenant_b[0].outputs.networks, {}) : {}
  myapp_networks      = var.firewall_enabled && var.vapp_myapp_enabled ? try(data.terraform_remote_state.myapp[0].outputs.networks, {}) : {}
  pf_networks         = var.firewall_enabled && var.vapp_pf_enabled ? try(data.terraform_remote_state.pf[0].outputs.networks, {}) : {}
  h3m_networks        = var.firewall_enabled && var.vapp_h3m_enabled ? try(data.terraform_remote_state.h3m[0].outputs.networks, {}) : {}
  hsm_networks        = var.firewall_enabled && var.vapp_hsm_enabled ? try(data.terraform_remote_state.hsm[0].outputs.networks, {}) : {}
  tenant_c_networks     = var.firewall_enabled && var.vapp_tenant_c_enabled ? try(data.terraform_remote_state.tenant_c[0].outputs.networks, {}) : {}
  tenant_d_networks      = var.firewall_enabled && var.vapp_tenant_d_enabled ? try(data.terraform_remote_state.tenant_d[0].outputs.networks, {}) : {}

  # Merge all networks for firewall interfaces
  all_networks = merge(
    local.wallet_networks,
    local.idm_networks,
    local.monitoring_networks,
    local.security_networks,
    local.access_networks,
    local.devops_networks,
    local.tenant_b_networks,
    local.myapp_networks,
    local.pf_networks,
    local.h3m_networks,
    local.hsm_networks,
    local.tenant_c_networks,
    local.tenant_d_networks
  )

  # Convert networks map to list for template iteration
  networks_list = [
    for key, net in local.all_networks : {
      name       = net.name
      gateway_ip = net.gateway_ip
    }
  ]

  # Render OPNsense interfaces XML config
  opnsense_interfaces_xml = var.firewall_enabled ? templatefile(
    "${path.module}/../../templates/opnsense-interfaces.xml.tftpl",
    {
      wan_ip      = var.firewall_wan_ip
      wan_subnet  = "24"
      wan_gateway = cidrhost(cidrsubnet("${var.firewall_wan_ip}/24", 0, 0), 1)
      networks    = local.networks_list
    }
  ) : ""
}

# Data source to get the OPNsense ISO from catalog
data "vcd_catalog" "firewall" {
  count = var.firewall_enabled ? 1 : 0

  org  = var.org_name
  name = var.firewall_iso_catalog
}

data "vcd_catalog_media" "opnsense_iso" {
  count = var.firewall_enabled ? 1 : 0

  org        = var.org_name
  catalog_id = data.vcd_catalog.firewall[0].id
  name       = var.firewall_iso_name
}

# NOTE: vcd_vm.opnsense is now defined in opnsense_nic_ordering.tf
# with proper NIC ordering based on nic_order from each network module.
# This duplicate has been removed to avoid Terraform errors.

# Write OPNsense interfaces config to a local file for reference
resource "local_file" "opnsense_interfaces_config" {
  count = var.firewall_enabled ? 1 : 0

  content  = local.opnsense_interfaces_xml
  filename = "${path.module}/../../generated/opnsense-interfaces.xml"

  file_permission = "0644"
}

# Write a summary of network interfaces for documentation
resource "local_file" "opnsense_interfaces_summary" {
  count = var.firewall_enabled ? 1 : 0

  content = <<-EOT
# OPNsense Interface Summary
# Generated by Terraform - Do not edit manually

WAN Interface (vmx0):
  IP: ${var.firewall_wan_ip}
  Network: ${var.firewall_wan_network}

LAN Interfaces:
%{for idx, net in local.networks_list~}
  opt${idx + 1} (vmx${idx + 1}):
    Name: ${net.name}
    IP: ${net.gateway_ip}
%{endfor~}

Total interfaces: ${length(local.networks_list) + 1}
EOT

  filename = "${path.module}/../../generated/opnsense-interfaces-summary.txt"

  file_permission = "0644"
}
