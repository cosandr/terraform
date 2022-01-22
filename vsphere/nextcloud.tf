resource "vsphere_tag" "nextcloud" {
  name        = "nextcloud"
  category_id = "${vsphere_tag_category.ansible_group.id}"
  description = "Nextcloud servers"
}

module "nextcloud" {
  source = "./modules/vm_from_tmpl"

  datacenter_id    = "${data.vsphere_datacenter.home.id}"
  datastore_id     = "${data.vsphere_datastore.vm.id}"
  network_id       = "${vsphere_distributed_port_group.vm.id}"
  resource_pool_id = "${data.vsphere_resource_pool.home.id}"
  template_name    = "templates/rocky_packer"
  vm_net           = "${var.vm_net_space}"

  cores  = 6
  memory = 6144

  name       = "nextcloud01"
  tags       = ["${vsphere_tag.nextcloud.id}"]
  ip_address = 60

  os_disk_size   = 20
  data_disks     = 1
  data_disk_size = 50
}