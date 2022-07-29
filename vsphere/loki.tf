resource "vsphere_tag" "loki" {
  name        = "loki"
  category_id = vsphere_tag_category.ansible_group.id
  description = "Loki servers"
}

module "loki" {
  source = "./modules/vm_from_tmpl"

  datacenter_id    = data.vsphere_datacenter.home.id
  datastore_id     = data.vsphere_datastore.vm.id
  resource_pool_id = data.vsphere_resource_pool.home.id
  template_name    = "templates/alma9_packer"

  cores  = 4
  memory = 4096

  count  = 1
  name   = format("%s%02s", "loki", count.index + 1)
  folder = "Backend"
  tags   = ["${vsphere_tag.loki.id}", "${vsphere_tag.autostart.id}"]

  ipv4_gateway = local.ipv4_gateways.vm
  networks = [
    {
      id           = vsphere_distributed_port_group.vm.id
      ipv4_address = cidrhost(var.vm_net_space, 25 + count.index)
      ipv4_netmask = 24
    }
  ]

  os_disk_size = 50
}
