# Terraform version constraints moved to versions.tf

data "vcd_catalog_vapp_template" "this" {
  org        = var.org_name
  catalog_id = data.vcd_catalog.this.id
  name       = var.template_name
}

data "vcd_catalog" "this" {
  org  = var.org_name
  name = var.catalog_name
}

resource "vcd_vapp_vm" "vm" {
  name             = "${var.dc_prefix}-${var.environment_name}-${var.app_prefix}-${var.vm_role}-${var.name_suffix}"
  description      = "Role: ${var.vm_role} | Env: ${var.environment_name} | Managed by Terraform"
  vapp_name        = var.vapp_name
  org              = var.org_name
  vdc              = var.vdc_name
  vapp_template_id = var.vapp_template_id != "" ? var.vapp_template_id : data.vcd_catalog_vapp_template.this.id
  storage_profile  = var.storage_profile
  power_on         = var.power_on

  # Dynamic block to handle override_template_disk conditionally
  dynamic "override_template_disk" {
    for_each = var.is_windows ? [] : [1]
    content {
      bus_type        = "paravirtual"
      size_in_mb      = var.root_disk_size_gb * 1024
      bus_number      = 0
      unit_number     = 0
      storage_profile = var.storage_profile
    }
  }

  memory = var.memory
  cpus   = var.cpus
  
  # Enable hot-plug for CPU and Memory
  cpu_hot_add_enabled    = true
  memory_hot_add_enabled = true
  
  computer_name = var.is_windows ? "${var.dc_prefix}-${var.vm_role}-${var.name_suffix}" : "${var.dc_prefix}-${var.environment_name}-${var.app_prefix}-${var.vm_role}-${var.name_suffix}"

  lifecycle {
    ignore_changes = [
      vapp_template_id,
      override_template_disk,
    ]
    precondition {
      condition     = var.cpus >= 1
      error_message = "Policy Violation: Production VMs must have at least 1 CPU."
    }
    precondition {
      condition     = var.memory >= 2048
      error_message = "Policy Violation: Production VMs must have at least 2048 MB of RAM."
    }
  }

  network {
    type               = "org"
    name               = var.network_name
    ip_allocation_mode = var.ip_allocation_mode
    ip                 = var.ip_allocation_mode == "MANUAL" ? var.ip_address : null
  }

  customization {
    enabled                    = true
    change_sid                 = true
    allow_local_admin_password = true
    auto_generate_password     = false
    admin_password             = var.default_password

    # OS-specific init scripts
    initscript = var.is_windows ? join("\n", [
      # Windows (modular scripts)
      file("${path.module}/templates/scripts-windows/00-header.ps1"),
      templatefile("${path.module}/templates/scripts-windows/10-hostname.ps1.tftpl", {
        NEW_HOSTNAME = "${var.dc_prefix}-${var.environment_name}-${var.app_prefix}-${var.vm_role}-${var.name_suffix}"
      }),
      templatefile("${path.module}/templates/scripts-windows/20-users.ps1.tftpl", {
        default_user     = var.default_user
        default_password = var.default_password
      }),
      templatefile("${path.module}/templates/scripts-windows/30-network.ps1.tftpl", {
        dns_servers = var.dns_servers
      }),
      file("${path.module}/templates/scripts-windows/40-rdp.ps1"),
      file("${path.module}/templates/scripts-windows/50-firewall.ps1"),
      file("${path.module}/templates/scripts-windows/60-disks.ps1"),
      file("${path.module}/templates/scripts-windows/70-winrm.ps1"),
      file("${path.module}/templates/scripts-windows/80-optimizations.ps1"),
      file("${path.module}/templates/scripts-windows/99-footer.ps1")
    ]) : join("\n", [
      # Ubuntu/Debian (modular scripts)
      file("${path.module}/templates/scripts-ubuntu/00-header.sh"),
      templatefile("${path.module}/templates/scripts-ubuntu/10-users.sh.tftpl", {
        default_user     = var.default_user
        default_password = var.default_password
        users          = var.users
        root_password  = var.root_password
      }),
      templatefile("${path.module}/templates/scripts-ubuntu/20-network.sh.tftpl", {
        ip_address  = var.ip_address
        gateway     = var.gateway
        dns_servers = var.dns_servers
      }),
      templatefile("${path.module}/templates/scripts-ubuntu/30-hostname.sh.tftpl", {
        dc_prefix        = var.dc_prefix
        app_prefix       = var.app_prefix
        environment_name = var.environment_name
        vm_role          = var.vm_role
        name_suffix      = var.name_suffix
      }),
      templatefile("${path.module}/templates/scripts-ubuntu/40-ssh.sh.tftpl", {
        users          = var.users
        allow_root_ssh = var.allow_root_ssh
      }),
      templatefile("${path.module}/templates/scripts-ubuntu/50-disks.sh.tftpl", {
        data_disks       = var.data_disks
        auto_mount_disks = var.auto_mount_disks
      }),
      file("${path.module}/templates/scripts-ubuntu/99-footer.sh")
    ])
  }

  metadata_entry {
    key         = "vm_role"
    value       = var.vm_role
    type        = "MetadataStringValue"
    user_access = "READWRITE"
    is_system   = false
  }
  metadata_entry {
    key         = "hostname"
    value       = "${var.dc_prefix}-${var.environment_name}-${var.app_prefix}-${var.vm_role}-${var.name_suffix}"
    type        = "MetadataStringValue"
    user_access = "READWRITE"
    is_system   = false
  }
  metadata_entry {
    key         = "environment"
    value       = var.environment_name
    type        = "MetadataStringValue"
    user_access = "READWRITE"
    is_system   = false
  }
  metadata_entry {
    key         = "created_by"
    value       = "terraform"
    type        = "MetadataStringValue"
    user_access = "READWRITE"
    is_system   = false
  }

  dynamic "metadata_entry" {
    for_each = var.custom_metadata
    content {
      key         = metadata_entry.key
      value       = metadata_entry.value
      type        = "MetadataStringValue"
      user_access = "READWRITE"
      is_system   = false
    }
  }
}

resource "vcd_vm_internal_disk" "data_disks" {
  for_each = var.data_disks
  org  = var.org_name         
  vdc  = var.vdc_name
  vapp_name = var.vapp_name
  vm_name   = vcd_vapp_vm.vm.name

  size_in_mb = each.value.size_gb * 1024
  bus_number = each.value.bus_number
  unit_number = each.value.unit_number
  bus_type        = var.is_windows ? "sas" : "paravirtual"
  storage_profile = var.storage_profile
  allow_vm_reboot = true
}