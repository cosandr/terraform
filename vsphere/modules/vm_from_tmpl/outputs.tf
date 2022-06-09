output "name" {
  value = vsphere_virtual_machine.vm.name
}

output "primary_ipv4_address" {
  value = vsphere_virtual_machine.vm.clone[0].customize[0].network_interface[0].ipv4_address
  # Might be needed after importing VMs
  # value = length(vsphere_virtual_machine.vm.clone) > 0 ? vsphere_virtual_machine.vm.clone[0].customize[0].network_interface[0].ipv4_address : null
}

output "domain" {
  value = var.domain
}
