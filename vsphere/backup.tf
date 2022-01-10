resource "vsphere_tag" "backup" {
  name        = "backup"
  category_id = "${vsphere_tag_category.ansible_group.id}"
  description = "Backup servers"
}

module "backup" {
  source = "./modules/vm_from_tmpl"

  datacenter_id    = "${data.vsphere_datacenter.home.id}"
  datastore_id     = "${data.vsphere_datastore.vm.id}"
  network_id       = "${vsphere_distributed_port_group.vm.id}"
  resource_pool_id = "${data.vsphere_resource_pool.home.id}"
  template_name    = "templates/rocky_packer"
  vm_net           = "${var.vm_net_space}"

  cores  = 8
  memory = 8192

  name       = "backup01"
  tags       = ["${vsphere_tag.backup.id}"]
  ip_address = 8

  os_disk_size   = 20
  data_disks     = 0
}
