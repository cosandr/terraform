resource "vsphere_tag" "pgbak" {
  name        = "pgbak"
  category_id = vsphere_tag_category.ansible_group.id
  description = "Postgres backup servers"
}

module "pgbak" {
  source = "./modules/vm_from_tmpl"

  datacenter_id    = data.vsphere_datacenter.home.id
  datastore_id     = data.vsphere_datastore.vm.id
  network_id       = vsphere_distributed_port_group.vm.id
  resource_pool_id = data.vsphere_resource_pool.home.id
  template_name    = "templates/alma9_packer"
  vm_net           = var.vm_net_space

  cores  = 4
  memory = 4096

  name       = "pgbak01"
  folder     = "PostgreSQL"
  tags       = ["${vsphere_tag.pgbak.id}", "${vsphere_tag.autostart.id}"]
  ip_address = 9

  os_disk_size = 20
}
