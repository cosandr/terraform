locals {
  kube_domain = "vm.hlab.no"
  kube_folder = "kube"
  kube_tags   = ["${vsphere_tag.kube.id}", "${vsphere_tag.autostart.id}"]

  kube_master_name   = "kube-master"
  kube_master_cores  = 4
  kube_master_memory = 4096
  kube_master_disk   = 20

  kube_worker_name   = "kube-worker"
  kube_worker_nodes  = 3
  kube_worker_cores  = 8
  kube_worker_memory = 8192
  kube_worker_disk   = 200
}

resource "vsphere_folder" "kube" {
  path          = "kube"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.home.id
}

resource "vsphere_tag" "kube" {
  name        = "kube"
  category_id = vsphere_tag_category.ansible_group.id
  description = "Kubernetes servers"
}

data "vsphere_virtual_machine" "kube_template" {
  name          = "templates/rocky_packer"
  datacenter_id = data.vsphere_datacenter.home.id
}

resource "vsphere_virtual_machine" "kube_master" {
  name             = local.kube_master_name
  resource_pool_id = data.vsphere_resource_pool.home.id
  datastore_id     = data.vsphere_datastore.vm.id

  num_cpus             = local.kube_master_cores
  num_cores_per_socket = local.kube_master_cores
  memory               = local.kube_master_memory
  guest_id             = data.vsphere_virtual_machine.kube_template.guest_id
  firmware             = data.vsphere_virtual_machine.kube_template.firmware
  folder               = local.kube_folder
  tags                 = local.kube_tags

  enable_disk_uuid = true

  scsi_type = data.vsphere_virtual_machine.kube_template.scsi_type

  network_interface {
    network_id   = vsphere_distributed_port_group.vm.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "os01"
    size             = local.kube_master_disk
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.kube_template.id

    customize {
      linux_options {
        host_name = local.kube_master_name
        domain    = local.kube_domain
      }

      network_interface {
        ipv4_address = "10.0.10.50"
        ipv4_netmask = 24
      }

      ipv4_gateway = "10.0.10.1"

      dns_server_list = [
        "10.0.10.1",
        "1.1.1.1",
        "8.8.8.8",
      ]
    }
  }

  lifecycle {
    ignore_changes = [
      clone[0].template_uuid,
      clone[0].customize[0].linux_options,
      clone[0].customize[0].network_interface,
      disk,
      network_interface[0].use_static_mac,
    ]
  }
}

resource "mikrotik_dns_record" "kube_master" {
  name    = "${vsphere_virtual_machine.kube_master.name}.${local.kube_domain}"
  address = vsphere_virtual_machine.kube_master.clone[0].customize[0].network_interface[0].ipv4_address
}

resource "vsphere_virtual_machine" "kube_worker" {
  count            = local.kube_worker_nodes
  name             = format("%s%02s", "${local.kube_worker_name}", count.index + 1)
  resource_pool_id = data.vsphere_resource_pool.home.id
  datastore_id     = data.vsphere_datastore.vm.id

  num_cpus             = local.kube_worker_cores
  num_cores_per_socket = local.kube_worker_cores
  memory               = local.kube_worker_memory
  guest_id             = data.vsphere_virtual_machine.kube_template.guest_id
  firmware             = data.vsphere_virtual_machine.kube_template.firmware
  folder               = local.kube_folder
  tags                 = local.kube_tags

  enable_disk_uuid = true

  scsi_type = data.vsphere_virtual_machine.kube_template.scsi_type

  network_interface {
    network_id   = vsphere_distributed_port_group.vm.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "os01"
    size             = local.kube_worker_disk
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.kube_template.id

    customize {
      linux_options {
        host_name = format("%s%02s", "${local.kube_worker_name}", count.index + 1)
        domain    = local.kube_domain
      }

      network_interface {
        ipv4_address = format("10.0.10.%d", 50 + count.index + 1)
        ipv4_netmask = 24
      }

      ipv4_gateway = "10.0.10.1"

      dns_server_list = [
        "10.0.10.1",
        "1.1.1.1",
        "8.8.8.8",
      ]
    }
  }

  lifecycle {
    ignore_changes = [
      clone[0].template_uuid,
      clone[0].customize[0].linux_options,
      clone[0].customize[0].network_interface,
      disk,
      network_interface[0].use_static_mac,
    ]
  }
}

resource "mikrotik_dns_record" "kube_worker" {
  count   = length(vsphere_virtual_machine.kube_worker)
  name    = "${vsphere_virtual_machine.kube_worker[count.index].name}.${local.kube_domain}"
  address = vsphere_virtual_machine.kube_worker[count.index].clone[0].customize[0].network_interface[0].ipv4_address
}
