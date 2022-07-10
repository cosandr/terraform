resource "vsphere_tag" "pg" {
  name        = "pg"
  category_id = vsphere_tag_category.ansible_group.id
  description = "PostgreSQL servers"
}

module "pg" {
  source = "./modules/vm_from_tmpl"

  datacenter_id    = data.vsphere_datacenter.home.id
  datastore_id     = data.vsphere_datastore.vm.id
  network_id       = vsphere_distributed_port_group.vm.id
  resource_pool_id = data.vsphere_resource_pool.home.id
  template_name    = "templates/rocky_packer"
  vm_net           = var.vm_net_space

  cores  = 12
  memory = 12288

  count      = 1
  name       = format("%s%02s", "pg", count.index + 1)
  folder     = "PostgreSQL"
  tags       = ["${vsphere_tag.pg.id}", "${vsphere_tag.autostart.id}"]
  ip_address = 10 + count.index + 1

  data_disks = [
    {
      "size" : 100
    },
  ]
}
