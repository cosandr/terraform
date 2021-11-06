data "vsphere_virtual_machine" "rocky" {
  name          = "templates/rocky_packer"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "rocky_docker" {
  name          = "templates/rocky_docker_packer"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
