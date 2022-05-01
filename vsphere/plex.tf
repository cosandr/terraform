resource "vsphere_tag" "plex" {
  name        = "plex"
  category_id = "${vsphere_tag_category.ansible_group.id}"
  description = "Plex servers"
}

module "plex" {
  source = "./modules/vm_from_tmpl"

  datacenter_id    = "${data.vsphere_datacenter.home.id}"
  datastore_id     = "${data.vsphere_datastore.vm.id}"
  network_id       = "${vsphere_distributed_port_group.vm.id}"
  resource_pool_id = "${data.vsphere_resource_pool.home.id}"
  template_name    = "templates/rocky_packer"
  vm_net           = "${var.vm_net_space}"

  cores  = 12
  memory = 10240

  name       = "plex01"
  folder     = "Services"
  tags       = ["${vsphere_tag.plex.id}", "${vsphere_tag.autostart.id}"]
  ip_address = 65

  os_disk_size   = 20

  data_disks = [
    {
      "size": 50
    },
  ]
}
