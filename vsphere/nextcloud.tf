resource "vsphere_tag" "nextcloud" {
  name        = "nextcloud"
  category_id = vsphere_tag_category.ansible_group.id
  description = "Nextcloud servers"
}

module "nextcloud" {
  source = "./modules/vm_from_tmpl"

  datacenter_id    = data.vsphere_datacenter.home.id
  datastore_id     = data.vsphere_datastore.vm.id
  resource_pool_id = data.vsphere_resource_pool.home.id
  template_name    = "templates/rocky_packer"

  cores  = 6
  memory = 6144

  name       = "nextcloud01"
  folder     = "Services"
  tags       = ["${vsphere_tag.nextcloud.id}", "${vsphere_tag.autostart.id}"]

  ipv4_gateway = local.ipv4_gateways.vm
  networks = [
    {
      id           = vsphere_distributed_port_group.vm.id
      ipv4_address = cidrhost(var.vm_net_space, 60)
      ipv4_netmask = 24
    }
  ]

  os_disk_size = 20

  data_disks = [
    {
      "size" : 50
    },
  ]
}
