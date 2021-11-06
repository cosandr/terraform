resource "vsphere_virtual_machine" "pg" {
  name             = "pg01"
  resource_pool_id = "${data.vsphere_resource_pool.slb.id}"
  datastore_id     = "${data.vsphere_datastore.tn_ssd.id}"

  num_cpus = 4
  num_cores_per_socket = 4
  memory   = 4096
  guest_id = "${data.vsphere_virtual_machine.rocky.guest_id}"
  firmware = "${data.vsphere_virtual_machine.rocky.firmware}"
  folder   = "Backend"

  scsi_type = "${data.vsphere_virtual_machine.rocky.scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.vlan10.id}"
    adapter_type = "${data.vsphere_virtual_machine.rocky.network_interface_types[0]}"
  }

  disk {
    label            = "os01"
    size             = "${data.vsphere_virtual_machine.rocky.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.rocky.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.rocky.disks.0.thin_provisioned}"
  }

  disk {
    label            = "data01"
    size             = "20"
    unit_number      = 1
    thin_provisioned = true
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.rocky.id}"

    customize {
      linux_options {
        host_name = "pg01"
        domain = "vm.local"
      }

      network_interface {
        ipv4_address = cidrhost(var.vm_net_space, 10)
        ipv4_netmask = split("/", var.vm_net_space)[1]
      }

      ipv4_gateway = cidrhost(var.vm_net_space, 1)

      dns_server_list = [
        cidrhost(var.vm_net_space, 1),
        "1.1.1.1",
        "8.8.8.8"
      ]
    }
  }
}
