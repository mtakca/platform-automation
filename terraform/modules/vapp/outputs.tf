output "vapp_name" {
  description = "Name of the created vApp"
  value       = vcd_vapp.this.name
}

output "vapp_id" {
  description = "ID of the created vApp"
  value       = vcd_vapp.this.id
}