resource "vsphere_tag" "prometheus" {
  name        = "prometheus"
  category_id = "${vsphere_tag_category.ansible_group.id}"
  description = "Prometheus servers"
}

module "prometheus" {
  source = "./modules/vm_from_tmpl"

  datacenter_id    = "${data.vsphere_datacenter.dc.id}"
  datastore_id     = "${data.vsphere_datastore.tn_ssd.id}"
  network_id       = "${data.vsphere_network.vlan10.id}"
  resource_pool_id = "${data.vsphere_resource_pool.slb.id}"
  template_name    = "templates/rocky_packer"
  vm_net           = "${var.vm_net_space}"

  cores  = 4
  memory = 4096

  count      = 1
  name       = format("%s%02s", "prom", count.index + 1)
  folder     = "Backend"
  tags       = ["${vsphere_tag.prometheus.id}"]
  ip_address = 20 + count.index + 1

  data_disks     = 1
  data_disk_size = 100
}
