output "vm_name" {
  description = "Deployed VM name"
  value       = vcd_vapp_vm.vm.name
}

output "vm_ip" {
  description = "VM IP address"
  value       = try(vcd_vapp_vm.vm.network[0].ip, null)
}

output "vm_role" {
  value = var.vm_role
}

output "vm_power_state" {
  value = vcd_vapp_vm.vm.power_on
}