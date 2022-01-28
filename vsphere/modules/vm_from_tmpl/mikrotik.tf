terraform {
  required_providers {
    mikrotik = {
      source = "ddelnano/mikrotik"
      version = "~> 0.8"
    }
  }
}

resource "mikrotik_dns_record" "vm" {
  count = var.add_mikrotik_dns ? 1 : 0
  name = "${vsphere_virtual_machine.vm.name}.${var.domain}"
  address = "${vsphere_virtual_machine.vm.clone[0].customize[0].network_interface[0].ipv4_address}"
}
