resource "vsphere_folder" "k3s" {
  path          = "k3s"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.home.id}"
}

resource "vsphere_tag" "k3s" {
  name        = "k3s"
  category_id = "${vsphere_tag_category.ansible_group.id}"
  description = "Kubernetes servers"
}

module "k3s" {
  source = "./modules/vm_from_tmpl"

  datacenter_id    = "${data.vsphere_datacenter.home.id}"
  datastore_id     = "${data.vsphere_datastore.vm.id}"
  network_id       = "${vsphere_distributed_port_group.vm.id}"
  resource_pool_id = "${data.vsphere_resource_pool.home.id}"
  template_name    = "templates/rocky_packer"
  vm_net           = "${var.vm_net_space}"

  cores  = 4
  memory = 8192

  count      = 3
  name       = format("%s%02s", "k3s", count.index + 1)
  folder     = "k3s"
  tags       = ["${vsphere_tag.k3s.id}"]
  ip_address = 50 + count.index + 1

  os_disk_size   = 200
}
