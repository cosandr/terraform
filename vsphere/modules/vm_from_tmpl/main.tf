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

  enable_disk_uuid     = "${var.enable_disk_uuid}"
  extra_config         = "${var.extra_config}"

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
    for_each = toset(range(0, length(var.data_disks)))
    iterator = item
    content {
      label            = format("data%02s", item.key + 1)
      size             = lookup(var.data_disks[item.key], "size", 100)
      unit_number      = lookup(var.data_disks[item.key], "unit", item.key + 1)
      thin_provisioned = lookup(var.data_disks[item.key], "thin", true)
      controller_type  = lookup(var.data_disks[item.key], "controller", "scsi")
      keep_on_remove   = lookup(var.data_disks[item.key], "keep_on_remove", false)
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
      disk[0].label,
      disk[1].label,
      disk[2].label,
      network_interface[0].use_static_mac,
      network_interface[1].use_static_mac,
      clone[0].template_uuid,
      clone[0].customize[0].linux_options,
      clone[0].customize[0].network_interface,
    ]
  }
}
