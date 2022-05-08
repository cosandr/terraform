resource "vsphere_folder" "kube" {
  path          = "kube"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.home.id}"
}

resource "vsphere_tag" "kube" {
  name        = "kube"
  category_id = "${vsphere_tag_category.ansible_group.id}"
  description = "Kubernetes servers"
}

module "kube_master" {
  source = "./modules/vm_from_tmpl"

  datacenter_id    = "${data.vsphere_datacenter.home.id}"
  datastore_id     = "${data.vsphere_datastore.vm.id}"
  network_id       = "${vsphere_distributed_port_group.vm.id}"
  resource_pool_id = "${data.vsphere_resource_pool.home.id}"
  template_name    = "templates/rocky_packer"
  vm_net           = "${var.vm_net_space}"

  cores  = 4
  memory = 4096

  extra_config = {
    "disk.EnableUUID" = "True"
  }

  name       = "kube-master"
  folder     = "kube"
  tags       = ["${vsphere_tag.kube.id}", "${vsphere_tag.autostart.id}"]
  ip_address = 50

  os_disk_size   = 20
}

module "kube_worker" {
  source = "./modules/vm_from_tmpl"

  datacenter_id    = "${data.vsphere_datacenter.home.id}"
  datastore_id     = "${data.vsphere_datastore.vm.id}"
  network_id       = "${vsphere_distributed_port_group.vm.id}"
  resource_pool_id = "${data.vsphere_resource_pool.home.id}"
  template_name    = "templates/rocky_packer"
  vm_net           = "${var.vm_net_space}"

  cores  = 8
  memory = 8192

  extra_config = {
    "disk.EnableUUID" = "True"
  }

  count      = 3
  name       = format("%s%02s", "kube-worker", count.index + 1)
  folder     = "kube"
  tags       = ["${vsphere_tag.kube.id}", "${vsphere_tag.autostart.id}"]
  ip_address = 50 + count.index + 1

  os_disk_size   = 200
}
