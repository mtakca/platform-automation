############################################################
# OPNSENSE FIREWALL VM - PROFESSIONAL NIC ORDERING
############################################################
#
# DESIGN PRINCIPLE: Ordering defined at SOURCE (network module),
# not at CONSUMER (firewall module).
#
# Each network module exports:
#   networks = {
#     network_key = {
#       name       = "network-name"
#       gateway_ip = "10.x.x.1"
#       nic_order  = N  # <-- Explicit order
#     }
#   }
#
# This module consumes and sorts by nic_order.
############################################################

locals {
  # Core networks from this module
  core_local_networks = var.firewall_enabled ? {
    core_infra = {
      name       = vcd_network_isolated.core_infra.name
      gateway_ip = vcd_network_isolated.core_infra.gateway
      nic_order  = 1  # vmx1 - Core-Infra (HAProxy, LB)
    }
    management = {
      name       = vcd_network_isolated.management.name
      gateway_ip = vcd_network_isolated.management.gateway
      nic_order  = 2  # vmx2 - Management (AD)
    }
  } : {}

  # Collect networks from all remote states
  all_networks_raw = merge(
    local.core_local_networks,
    var.firewall_enabled && var.vapp_wallet_enabled ? try(data.terraform_remote_state.wallet[0].outputs.networks, {}) : {},
    var.firewall_enabled && var.vapp_idm_enabled ? try(data.terraform_remote_state.idm[0].outputs.networks, {}) : {},
    var.firewall_enabled && var.vapp_monitoring_enabled ? try(data.terraform_remote_state.monitoring[0].outputs.networks, {}) : {},
    var.firewall_enabled && var.vapp_security_enabled ? try(data.terraform_remote_state.security[0].outputs.networks, {}) : {},
    var.firewall_enabled && var.vapp_access_enabled ? try(data.terraform_remote_state.access[0].outputs.networks, {}) : {},
    var.firewall_enabled && var.vapp_devops_enabled ? try(data.terraform_remote_state.devops[0].outputs.networks, {}) : {},
    var.firewall_enabled && var.vapp_tenant_b_enabled ? try(data.terraform_remote_state.tenant_b[0].outputs.networks, {}) : {},
    var.firewall_enabled && var.vapp_myapp_enabled ? try(data.terraform_remote_state.myapp[0].outputs.networks, {}) : {},
    var.firewall_enabled && var.vapp_pf_enabled ? try(data.terraform_remote_state.pf[0].outputs.networks, {}) : {},
    var.firewall_enabled && var.vapp_h3m_enabled ? try(data.terraform_remote_state.h3m[0].outputs.networks, {}) : {},
    var.firewall_enabled && var.vapp_hsm_enabled ? try(data.terraform_remote_state.hsm[0].outputs.networks, {}) : {},
    var.firewall_enabled && var.vapp_tenant_c_enabled ? try(data.terraform_remote_state.tenant_c[0].outputs.networks, {}) : {},
    var.firewall_enabled && var.vapp_tenant_d_enabled ? try(data.terraform_remote_state.tenant_d[0].outputs.networks, {}) : {}
  )

  # Sort networks by nic_order field (networks without nic_order get 999)
  networks_sorted = [
    for net in values({
      for k, v in local.all_networks_raw : k => {
        key        = k
        name       = v.name
        gateway_ip = v.gateway_ip
        nic_order  = try(v.nic_order, 999)
      }
    }) : net
  ]

  # Sort by nic_order using sort + lookup pattern
  networks_by_order = {
    for net in local.networks_sorted : format("%03d-%s", net.nic_order, net.key) => net
  }

  networks_ordered = [
    for k in sort(keys(local.networks_by_order)) : local.networks_by_order[k]
  ]
}

resource "vcd_vm" "opnsense" {
  count = var.firewall_enabled ? 1 : 0

  name        = "${var.dc_prefix}-${var.environment_name}-${var.app_prefix}-int-sfw-01"
  description = "OPNsense Firewall | Env: ${var.environment_name} | Managed by Terraform"
  org         = var.org_name
  vdc         = var.vdc_name

  boot_image_id    = data.vcd_catalog_media.opnsense_iso[0].id
  computer_name    = "${var.dc_prefix}-${var.environment_name}-${var.app_prefix}-int-sfw-01"
  os_type          = "otherGuest64"
  hardware_version = "vmx-21"

  cpus            = var.firewall_cpus
  memory          = var.firewall_memory
  storage_profile = var.storage_profile

  override_template_disk {
    bus_type        = "paravirtual"
    size_in_mb      = var.firewall_disk_size
    bus_number      = 0
    unit_number     = 0
    storage_profile = var.storage_profile
  }

  # WAN interface - ALWAYS vmx0
  network {
    type               = "org"
    name               = var.firewall_wan_network
    ip_allocation_mode = "MANUAL"
    ip                 = var.firewall_wan_ip
    is_primary         = true
    adapter_type       = "VMXNET3"
  }

  # LAN interfaces - ORDERED by nic_order from source modules
  dynamic "network" {
    for_each = local.networks_ordered
    content {
      type               = "org"
      name               = network.value.name
      ip_allocation_mode = "MANUAL"
      ip                 = network.value.gateway_ip
      adapter_type       = "VMXNET3"
    }
  }

  cpu_hot_add_enabled    = true
  memory_hot_add_enabled = true
  power_on               = true

  depends_on = [module.vapp]

  lifecycle {
    # Prevent NIC reordering on unrelated changes
    ignore_changes = [
      network[0].mac,
      network[1].mac,
      network[2].mac,
      network[3].mac,
    ]
  }
}

# Output sorted interface summary for verification
output "opnsense_interface_order" {
  description = "OPNsense NIC order (vmx0=WAN, vmx1+=LAN)"
  value = concat(
    [{ nic = "vmx0", name = var.firewall_wan_network, ip = var.firewall_wan_ip, order = 0 }],
    [for idx, net in local.networks_ordered : {
      nic   = "vmx${idx + 1}"
      name  = net.name
      ip    = net.gateway_ip
      order = net.nic_order
    }]
  )
}
