resource "vsphere_tag" "storage_vm" {
  name        = "storage_vm"
  category_id = "${vsphere_tag_category.storage.id}"
  description = "Datastores used for VM placement"
}

resource "vsphere_tag" "storage_tanzu" {
  name        = "storage_tanzu"
  category_id = "${vsphere_tag_category.storage.id}"
  description = "Datastores used for Tanzu"
}

resource "vsphere_tag" "storage_data" {
  name        = "storage_data"
  category_id = "${vsphere_tag_category.storage.id}"
  description = "Datastores excluded from VM placement"
}

resource "vsphere_vm_storage_policy" "vm" {
  name        = "VM Tag Policy"

  tag_rules {
    tag_category                 = "${vsphere_tag_category.storage.name}"
    tags                         = ["${vsphere_tag.storage_vm.name}"]
    include_datastores_with_tags = true
  }

}

resource "vsphere_vm_storage_policy" "data" {
  name        = "Data Tag Policy"

  tag_rules {
    tag_category                 = "${vsphere_tag_category.storage.name}"
    tags                         = ["${vsphere_tag.storage_data.name}"]
    include_datastores_with_tags = false
  }

}

resource "vsphere_vm_storage_policy" "tanzu" {
  name        = "Taznu Tag Policy"

  tag_rules {
    tag_category                 = "${vsphere_tag_category.storage.name}"
    tags                         = ["${vsphere_tag.storage_tanzu.name}"]
    include_datastores_with_tags = true
  }

}

resource "vsphere_vmfs_datastore" "esxi" {
  name           = "ESXi"
  host_system_id = "${data.vsphere_host.host[0].id}"

  disks = [
    "t10.ATA_____SAMSUNG_MZ7WD120HAFV2D00003______________S16KNYAF400837______",
  ]

  tags = ["${vsphere_tag.storage_vm.id}"]

  lifecycle {
    prevent_destroy = true
  }
}

resource "vsphere_vmfs_datastore" "local" {
  name           = "Local-Data"
  host_system_id = "${data.vsphere_host.host[0].id}"

  disks = [
    "t10.NVMe____Samsung_SSD_980_1TB_____________________9850B011D9382500",
  ]

  tags = ["${vsphere_tag.storage_vm.id}"]

  lifecycle {
    prevent_destroy = true
  }
}

resource "vsphere_nas_datastore" "vm" {
  name            = "TrueNAS-VM"
  host_system_ids = data.vsphere_host.host.*.id

  type          = "NFS41"
  security_type = "AUTH_SYS"
  remote_hosts  = ["${var.truenas_ip}"]
  remote_path   = "/mnt/ssd/vm"

  tags = ["${vsphere_tag.storage_vm.id}", "${vsphere_tag.storage_tanzu.id}"]
}

resource "vsphere_nas_datastore" "extra" {
  name            = "TrueNAS-Extra"
  host_system_ids = data.vsphere_host.host.*.id

  type          = "NFS41"
  security_type = "AUTH_SYS"
  remote_hosts  = ["${var.truenas_ip}"]
  remote_path   = "/mnt/extra/esxi"

  tags = ["${vsphere_tag.storage_vm.id}"]
}

resource "vsphere_nas_datastore" "disk-images" {
  name            = "TrueNAS-Disk-Images"
  host_system_ids = data.vsphere_host.host.*.id

  type          = "NFS41"
  security_type = "AUTH_SYS"
  remote_hosts  = ["${var.truenas_ip}"]
  remote_path   = "/mnt/tank/archive/disk-images"

  tags = ["${vsphere_tag.storage_data.id}"]
}
