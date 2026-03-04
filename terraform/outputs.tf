############################################################
# OUTPUTS
############################################################

# vApp outputs
output "vapp_name" {
  description = "Name of the vApp"
  value       = module.vapp.vapp_name
}

output "org_name" {
  description = "Organization name"
  value       = var.org_name
}

output "vdc_name" {
  description = "VDC name"
  value       = var.vdc_name
}

output "storage_profile" {
  description = "Storage profile"
  value       = var.storage_profile
}

# Networks from all vApps (via remote state)
output "wallet_networks" {
  description = "Networks from wallet module"
  value       = local.wallet_networks
}

output "idm_networks" {
  description = "Networks from IDM module"
  value       = local.idm_networks
}

output "monitoring_networks" {
  description = "Networks from monitoring module"
  value       = local.monitoring_networks
}

output "security_networks" {
  description = "Networks from security module"
  value       = local.security_networks
}

output "access_networks" {
  description = "Networks from access module"
  value       = local.access_networks
}

output "devops_networks" {
  description = "Networks from devops module"
  value       = local.devops_networks
}

output "all_firewall_networks" {
  description = "All networks connected to the firewall"
  value       = local.all_networks
}

# Firewall outputs
output "opnsense_vm_name" {
  description = "OPNsense firewall VM name"
  value       = var.firewall_enabled ? vcd_vm.opnsense[0].name : null
}

output "opnsense_interfaces" {
  description = "OPNsense network interfaces configuration"
  value = var.firewall_enabled ? [
    for idx, net in vcd_vm.opnsense[0].network : {
      index      = idx
      device     = "vmx${idx}"  # VMXNET3 adapter = vmx device in FreeBSD/OPNsense
      role       = idx == 0 ? "wan" : idx == 1 ? "lan" : "opt${idx - 1}"
      network    = net.name
      ip         = net.ip
      mac        = net.mac
      is_primary = net.is_primary
    }
  ] : []
}

output "opnsense_wan_ip" {
  description = "OPNsense WAN IP address"
  value       = var.firewall_enabled ? var.firewall_wan_ip : null
}

output "opnsense_lan_ips" {
  description = "Map of OPNsense LAN interface IPs (from all networks)"
  value = var.firewall_enabled ? {
    for key, net in local.all_networks : key => net.gateway_ip
  } : {}
}

output "opnsense_interfaces_xml" {
  description = "Generated OPNsense interfaces XML configuration"
  value       = local.opnsense_interfaces_xml
  sensitive   = false
}

output "opnsense_networks_list" {
  description = "List of networks configured on OPNsense"
  value       = local.networks_list
}
