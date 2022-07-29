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

  nested_hv_enabled      = "${var.nested_hv_enabled}"
  cpu_hot_add_enabled    = "${var.cpu_hot_add_enabled}"
  cpu_hot_remove_enabled = "${var.cpu_hot_remove_enabled}"
  memory_hot_add_enabled = "${var.memory_hot_add_enabled}"

  dynamic "network_interface" {
    for_each = toset(range(0, length(var.networks)))
    iterator = item
    content {
      network_id   = var.networks[item.key].id
      adapter_type = lookup(var.networks[item.key], "adapter_type", data.vsphere_virtual_machine.template.network_interface_types[0])
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
        host_name = var.host_name != null ? var.host_name : var.name
        domain = "${var.domain}"
      }

      dynamic "network_interface" {
        for_each = toset(range(0, length(var.networks)))
        iterator = item
        content {
          ipv4_address = lookup(var.networks[item.key], "ipv4_address", null)
          ipv4_netmask = lookup(var.networks[item.key], "ipv4_netmask", null)
          ipv6_address = lookup(var.networks[item.key], "ipv6_address", null)
          ipv6_netmask = lookup(var.networks[item.key], "ipv6_netmask", null)
        }
      }

      ipv4_gateway = var.ipv4_gateway
      ipv6_gateway = var.ipv6_gateway

      dns_server_list = [
        var.ipv4_gateway,
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
