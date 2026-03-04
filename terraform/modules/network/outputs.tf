# output "routed_network_ids" {
#   value = { for k, v in vcd_network_routed.routed : k => v.id }
# }

output "isolated_network_ids" {
  value = { for k, v in vcd_network_isolated.isolated : k => v.id }
}

output "org_network_ids" {
  value = merge(
    { for k, v in data.vcd_network_routed.org : k => v.id },
    { for k, v in data.vcd_network_direct.org_direct : k => v.id }
  )
}

output "network_ids" {
  description = "Unified map of all network IDs (routed, isolated, and org)"
  value = merge(
    { for k, v in vcd_network_isolated.isolated : k => v.id },
    { for k, v in data.vcd_network_routed.org : k => v.id },
    { for k, v in data.vcd_network_direct.org_direct : k => v.id }
  )
}

output "network_names" {
  value = local.network_names
}

output "network_cidrs" {
  value = { for k, v in var.subnets : k => v.cidr }
}
