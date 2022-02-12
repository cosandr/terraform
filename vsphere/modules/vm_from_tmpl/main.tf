data "vsphere_virtual_machine" "template" {
  name          = "${var.template_name}"
  datacenter_id = "${var.datacenter_id}"
}

resource "vsphere_virtual_machine" "vm" {
  name                 = "${var.name}"
  resource_pool_id     = "${var.resource_pool_id}"
  datastore_id         = "${var.datastore_id}"

  num_cpus             = "${var.cores}"
  num_cores_per_socket = "${var.cores}"
  memory               = "${var.memory}"
  guest_id             = "${data.vsphere_virtual_machine.template.guest_id}"
  firmware             = "${data.vsphere_virtual_machine.template.firmware}"
  folder               = "${var.folder}"
  tags                 = "${var.tags}"

  scsi_type            = "${data.vsphere_virtual_machine.template.scsi_type}"

  storage_policy_id    = "${var.storage_policy_id}"

  network_interface {
    network_id   = "${var.network_id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  dynamic "network_interface" {
    for_each = var.extra_networks
    iterator = item
    content {
      network_id   = "${item.value.id}"
      adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
    }
  }

  disk {
    label            = "os01"
    size             = var.os_disk_size != null ? var.os_disk_size : "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  dynamic "disk" {
    for_each = toset(range(1, var.data_disks + 1))
    iterator = item
    content {
      label            = format("data%02s", item.key)
      size             = "${var.data_disk_size}"
      unit_number      = item.key
      thin_provisioned = true
    }
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "${var.name}"
        domain = "${var.domain}"
      }

      network_interface {
        ipv4_address = cidrhost("${var.vm_net}", "${var.ip_address}")
        ipv4_netmask = split("/", "${var.vm_net}")[1]
      }

      dynamic "network_interface" {
        for_each = var.extra_networks
        iterator = item
        content {
          ipv4_address = cidrhost("${item.value.cidr}", "${item.value.host}")
          ipv4_netmask = split("/", "${item.value.cidr}")[1]
        }
      }

      ipv4_gateway = cidrhost("${var.vm_net}", 1)

      dns_server_list = [
        cidrhost("${var.vm_net}", 1),
        "1.1.1.1",
        "8.8.8.8"
      ]
    }
  }

  lifecycle {
    ignore_changes = [
      clone[0].template_uuid,
      clone[0].customize[0].linux_options,
      clone[0].customize[0].network_interface,
    ]
  }
}
