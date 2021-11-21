resource "vsphere_folder" "elk" {
  path          = "ELK"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.home.id}"
}

resource "vsphere_tag" "elasticsearch" {
  name        = "elasticsearch"
  category_id = "${vsphere_tag_category.ansible_group.id}"
  description = "Elasticsearch servers"
}

resource "vsphere_tag" "logstash" {
  name        = "logstash"
  category_id = "${vsphere_tag_category.ansible_group.id}"
  description = "Logstash servers"
}

resource "vsphere_tag" "kibana" {
  name        = "kibana"
  category_id = "${vsphere_tag_category.ansible_group.id}"
  description = "Kibana servers"
}

module "elasticsearch" {
  source = "./modules/vm_from_tmpl"

  datacenter_id    = "${data.vsphere_datacenter.home.id}"
  datastore_id     = "${data.vsphere_datastore.tn_ssd.id}"
  network_id       = "${data.vsphere_network.vm.id}"
  resource_pool_id = "${data.vsphere_resource_pool.home.id}"
  template_name    = "templates/rocky_packer"
  vm_net           = "${var.vm_net_space}"

  cores  = 4
  memory = 12288

  count      = 3
  name       = format("%s%02s", "es", count.index + 1)
  folder     = "ELK"
  tags       = ["${vsphere_tag.elasticsearch.id}"]
  ip_address = 30 + count.index + 1

  data_disks     = 1
  data_disk_size = 50
}

module "logkib" {
  source = "./modules/vm_from_tmpl"

  datacenter_id    = "${data.vsphere_datacenter.home.id}"
  datastore_id     = "${data.vsphere_datastore.tn_ssd.id}"
  network_id       = "${data.vsphere_network.vm.id}"
  resource_pool_id = "${data.vsphere_resource_pool.home.id}"
  template_name    = "templates/rocky_packer"
  vm_net           = "${var.vm_net_space}"

  cores  = 4
  memory = 8192

  name       = "logkib01"
  folder     = "ELK"
  tags       = ["${vsphere_tag.logstash.id}", "${vsphere_tag.kibana.id}"]
  ip_address = 30

  os_disk_size = 30
  data_disks   = 0
}
