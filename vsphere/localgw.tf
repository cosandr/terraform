resource "vsphere_tag" "localgw" {
  name        = "localgw"
  category_id = vsphere_tag_category.ansible_group.id
  description = "Local gateways"
}

module "localgw" {
  source = "./modules/vm_from_tmpl"

  datacenter_id    = data.vsphere_datacenter.home.id
  datastore_id     = data.vsphere_datastore.vm.id
  network_id       = vsphere_distributed_port_group.vm.id
  resource_pool_id = data.vsphere_resource_pool.home.id
  template_name    = "templates/rocky_packer"
  vm_net           = var.vm_net_space

  cores  = 4
  memory = 4096

  count      = 1
  name       = format("%s%02s", "localgw", count.index + 1)
  folder     = "Backend"
  tags       = ["${vsphere_tag.localgw.id}", "${vsphere_tag.autostart.id}"]
  ip_address = 91 + count.index

  os_disk_size = 20
  data_disks   = []
}
