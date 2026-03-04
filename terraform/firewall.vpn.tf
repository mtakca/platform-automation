
resource "vcd_vm" "firewall_vpn" {
  count = var.firewall_vpn_enabled ? 1 : 0

  name        = "${var.dc_prefix}-${var.environment_name}-${var.app_prefix}-vpn-sfw-01"
  description = "OPNsense Firewall | Env: ${var.environment_name} | Managed by Terraform"
  #vapp_name   = module.vapp.vapp_name
  org         = var.org_name
  vdc         = var.vdc_name

  # Boot from ISO (empty VM)
  boot_image_id    = data.vcd_catalog_media.opnsense_iso[0].id
  computer_name    = "${var.dc_prefix}-${var.environment_name}-${var.app_prefix}-vpn-sfw-01"
  os_type          = "otherGuest64"
  hardware_version = "vmx-19"

  # Hardware configuration
  cpus            = var.firewall_cpus
  memory          = var.firewall_memory
  storage_profile = var.storage_profile

  # OS disk (internal disk for empty VM)
  override_template_disk {
    bus_type        = "paravirtual"
    size_in_mb      = var.firewall_disk_size
    bus_number      = 0
    unit_number     = 0
    storage_profile = var.storage_profile
  }

 

  # VPN External interface
  network {
    type               = "org"
    name               = var.firewall_vpn_external_network
    ip_allocation_mode = "MANUAL"
    ip                 = var.firewall_vpn_external_ip
    is_primary         = false
    adapter_type       = "VMXNET3"
  }

  # VPN Internal interface
  network {
    type               = "org"
    name               = var.firewall_vpn_internal_network
    ip_allocation_mode = "MANUAL"
    ip                 = var.firewall_vpn_internal_ip
    is_primary         = false
    adapter_type       = "VMXNET3"
  }

  # Enable hot-plug for CPU and Memory
  cpu_hot_add_enabled    = true
  memory_hot_add_enabled = true

  # Power on after creation
  power_on = true

  depends_on = [
    module.vapp,
  ]
}
