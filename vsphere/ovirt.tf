resource "vsphere_tag" "ovirt" {
  name        = "ovirt"
  category_id = vsphere_tag_category.ansible_group.id
  description = "oVirt servers"
}

module "ovirt" {
  source = "./modules/vm_from_tmpl"

  datacenter_id    = data.vsphere_datacenter.home.id
  datastore_id     = data.vsphere_datastore.vm.id
  resource_pool_id = data.vsphere_resource_pool.home.id
  template_name    = "templates/rocky_packer"


  cores  = 4
  memory = 8192

  count  = 3
  name   = format("%s%02s", "ovirt", count.index + 1)
  folder = "oVirt"
  tags   = ["${vsphere_tag.ovirt.id}"]

  ipv4_gateway = local.ipv4_gateways.mgmt
  networks = [
    {
      id           = vsphere_distributed_port_group.mgmt.id
      ipv4_address = cidrhost(var.mgmt_net_space, 131 + count.index)
      ipv4_netmask = 24
    },
    {
      id = vsphere_distributed_port_group.trunk.id
    }
  ]
  os_disk_size = 64
  data_disks   = []
}
