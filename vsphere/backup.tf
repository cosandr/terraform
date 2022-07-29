resource "vsphere_tag" "backup" {
  name        = "backup"
  category_id = vsphere_tag_category.ansible_group.id
  description = "Backup servers"
}

module "backup" {
  source = "./modules/vm_from_tmpl"

  datacenter_id    = data.vsphere_datacenter.home.id
  datastore_id     = data.vsphere_datastore.vm.id
  resource_pool_id = data.vsphere_resource_pool.home.id
  template_name    = "templates/rocky_packer"

  cores  = 8
  memory = 8192

  name       = "backup01"
  folder     = "Services"
  tags       = ["${vsphere_tag.backup.id}", "${vsphere_tag.autostart.id}"]

  ipv4_gateway = local.ipv4_gateways.vm
  networks = [
    {
      id           = vsphere_distributed_port_group.vm.id
      ipv4_address = cidrhost(var.vm_net_space, 8)
      ipv4_netmask = 24
    }
  ]

  os_disk_size = 20
  data_disks   = []
}
