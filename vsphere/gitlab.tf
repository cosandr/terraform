resource "vsphere_folder" "gitlab" {
  path          = "GitLab"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.home.id}"
}

resource "vsphere_tag" "gitlab" {
  name        = "gitlab"
  category_id = "${vsphere_tag_category.ansible_group.id}"
  description = "Gitlab servers"
}

resource "vsphere_tag" "gitrun" {
  name        = "gitrun"
  category_id = "${vsphere_tag_category.ansible_group.id}"
  description = "Gitlab runners"
}

module "gitlab" {
  source = "./modules/vm_from_tmpl"

  datacenter_id    = "${data.vsphere_datacenter.home.id}"
  datastore_id     = "${data.vsphere_datastore.vm.id}"
  network_id       = "${vsphere_distributed_port_group.vm.id}"
  resource_pool_id = "${data.vsphere_resource_pool.home.id}"
  template_name    = "templates/rocky_packer"
  vm_net           = "${var.vm_net_space}"

  cores  = 4
  memory = 8192

  name       = "gitlab01"
  folder     = "GitLab"
  tags       = ["${vsphere_tag.gitlab.id}", "${vsphere_tag.autostart.id}"]
  ip_address = 40

  os_disk_size = 20
  data_disks   = [
    {
      "size": 30
    }
  ]
}

module "gitrun" {
  source = "./modules/vm_from_tmpl"

  datacenter_id    = "${data.vsphere_datacenter.home.id}"
  datastore_id     = "${data.vsphere_datastore.vm.id}"
  network_id       = "${vsphere_distributed_port_group.vm.id}"
  resource_pool_id = "${data.vsphere_resource_pool.home.id}"
  template_name    = "templates/rocky_packer"
  vm_net           = "${var.vm_net_space}"

  cores  = 4
  memory = 4096

  count      = 2
  name       = format("%s%02s", "gitrun", count.index + 1)
  folder     = "GitLab"
  tags       = ["${vsphere_tag.gitrun.id}", "${vsphere_tag.autostart.id}"]
  ip_address = 40 + count.index + 1

  data_disks = [
    {
      "size": 20
    },
  ]
}
