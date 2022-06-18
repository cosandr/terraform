resource "vsphere_tag" "loki" {
  name        = "loki"
  category_id = "${vsphere_tag_category.ansible_group.id}"
  description = "Loki servers"
}

module "loki" {
  source = "./modules/vm_from_tmpl"

  datacenter_id    = "${data.vsphere_datacenter.home.id}"
  datastore_id     = "${vsphere_vmfs_datastore.local.id}"
  network_id       = "${vsphere_distributed_port_group.vm.id}"
  resource_pool_id = "${data.vsphere_resource_pool.home.id}"
  template_name    = "templates/alma9_packer"
  vm_net           = "${var.vm_net_space}"

  cores  = 4
  memory = 4096

  count      = 1
  name       = format("%s%02s", "loki", count.index + 1)
  folder     = "Backend"
  tags       = ["${vsphere_tag.loki.id}", "${vsphere_tag.autostart.id}"]
  ip_address = 24 + count.index + 1

  os_disk_size = 50

  storage_policy_id = "${data.vsphere_storage_policy.encryption.id}"
}
