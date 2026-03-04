############################################################
# CORE INFRASTRUCTURE - VM DEPLOYMENT
# ------------------------------------------------------------------------------
# HAProxy, Load Balancers, and other Core VMs
############################################################

############################################################
# BASE INFRA DATA LOOKUP (for template)
############################################################
module "base_infra" {
  source    = "./modules/base_infra"
  providers = { vcd = vcd }

  count = length(var.node_pools) > 0 ? 1 : 0

  vcd_url         = var.vcd_url
  org_name        = var.org_name
  ovdc_name       = var.vdc_name
  catalog_name    = var.catalog_name
  template_name   = var.template_name
  storage_profile = var.storage_profile
  gateway         = var.gateway
}

############################################################
# DYNAMIC VM CALCULATION
############################################################
locals {
  # Map network name suffixes to their vcd_network_isolated resources
  vm_networks = {
    "core-infra-vnet" = {
      resource      = vcd_network_isolated.core_infra
      gateway       = vcd_network_isolated.core_infra.gateway
      prefix_length = 24
    }
    "management-vnet" = {
      resource      = vcd_network_isolated.management
      gateway       = vcd_network_isolated.management.gateway
      prefix_length = 24
    }
  }

  # Flatten the map of node pools into a list of individual VMs
  vms = merge([
    for pool_name, pool in var.node_pools : {
      for i in range(pool.count) :
      "${var.dc_prefix}-${var.environment_name}-${var.app_prefix}-${pool_name}-${format("%02d", i + 1)}" => {
        vm_role           = pool.role
        name_suffix       = format("%02d", i + 1)
        ip_offset         = pool.ip_start_offset + i
        cpus              = pool.cpus
        memory            = pool.memory
        data_disks        = pool.data_disks
        auto_mount_disks  = pool.auto_mount_disks
        harden            = pool.harden
        audit_enable      = pool.audit_enable
        allow_root_ssh    = pool.allow_root_ssh
        install_cloudinit = pool.install_cloudinit
        custom_metadata   = pool.custom_metadata
        dns_servers       = join(",", var.dns_servers)

        # Overrides
        template_name = coalesce(pool.template_name, var.template_name)
        catalog_name  = coalesce(pool.catalog_name, var.catalog_name)
        is_windows    = pool.is_windows

        network_name = local.vm_networks[pool.network_name].resource.name
        network_cidr = "${cidrhost("${local.vm_networks[pool.network_name].gateway}/${local.vm_networks[pool.network_name].prefix_length}", 0)}/${local.vm_networks[pool.network_name].prefix_length}"
        gateway      = local.vm_networks[pool.network_name].gateway
      }
    }
  ]...)
}

############################################################
# GENERIC VM DEPLOYMENT
############################################################
module "vms" {
  source    = "./modules/base_vm_template"
  providers = { vcd = vcd }

  for_each = local.vms

  vm_role     = each.value.vm_role
  name_suffix = each.value.name_suffix
  ip_address  = cidrhost(each.value.network_cidr, each.value.ip_offset)

  org_name        = var.org_name
  vdc_name        = var.vdc_name
  vapp_name       = module.vapp.vapp_name
  network_name    = each.value.network_name
  storage_profile = data.vcd_storage_profile.storage.name

  # Dynamic Template Selection
  catalog_name  = each.value.catalog_name
  template_name = each.value.template_name
  is_windows    = each.value.is_windows

  # vapp_template_id is now optional/fallback
  vapp_template_id = ""

  dc_prefix        = var.dc_prefix
  app_prefix       = var.app_prefix
  environment_name = var.environment_name

  cpus             = each.value.cpus
  memory           = each.value.memory
  data_disks       = each.value.data_disks
  auto_mount_disks = each.value.auto_mount_disks
  users            = var.users

  root_password  = var.root_password
  default_password = var.default_password

  harden            = each.value.harden
  audit_enable      = each.value.audit_enable
  allow_root_ssh    = each.value.allow_root_ssh
  install_cloudinit = each.value.install_cloudinit
  dns_servers       = each.value.dns_servers
  custom_metadata   = each.value.custom_metadata

  gateway = each.value.gateway

  depends_on = [
    module.vapp,
    vcd_vapp_org_network.core_infra,
    vcd_vapp_org_network.management
  ]
}

############################################################
# ANSIBLE INVENTORY GENERATION (Per-Service)
############################################################
locals {
  # Group VMs by role for Ansible inventory
  groups = {
    for role in distinct([for vm in local.vms : vm.vm_role]) :
    role => [
      for name, vm in module.vms :
      name
      if vm.vm_role == role
    ]
  }

  # Build service VMs map for inventory generation
  service_vms = {
    for role, names in local.groups :
    role => {
      for name in names :
      name => module.vms[name]
    }
  }

  # Calculate priorities based on VM index (100, 90, 80, ...)
  service_priorities = {
    for role, names in local.groups :
    role => {
      for idx, name in names :
      name => 100 - (idx * 10)
    }
  }
}

resource "local_file" "service_inventories" {
  for_each = local.service_vms

  content = templatefile("${path.module}/../templates/service-inventory.yaml.tftpl", {
    vms                   = each.value
    service_name          = each.key
    ansible_user          = var.ansible_user
    ansible_password      = var.default_password
    keepalived_vip        = try(var.service_config[each.key].vip, "")
    keepalived_vrid       = try(var.service_config[each.key].vrid, 0)
    keepalived_check_script = try(var.service_config[each.key].check_script, "")
    keepalived_priorities = merge(
      local.service_priorities[each.key],
      try(var.service_config[each.key].priorities, {})
    )
    host_vars  = {}
    extra_vars = {}
  })

  filename = "${path.module}/../environments/${var.environment_name}/${var.app_prefix}/${each.key}/hosts.yaml"

  # Ensure directory exists
  provisioner "local-exec" {
    command = "mkdir -p $(dirname ${self.filename})"
  }
}
