output "name" {
  value = vsphere_virtual_machine.vm.name
}

output "primary_ipv4_address" {
  value = vsphere_virtual_machine.vm.clone[0].customize[0].network_interface[0].ipv4_address
}

output "domain" {
  value = var.domain
}
