resource "vsphere_distributed_virtual_switch" "dvs" {
  name          = "DSwitch"
  datacenter_id = "${data.vsphere_datacenter.home.id}"

  uplinks         = ["uplink1", "uplink2"]
  active_uplinks  = ["uplink1", "uplink2"]
  standby_uplinks = []

  host {
    host_system_id = "${data.vsphere_host.host.0.id}"
    devices        = "${var.dvs_network_interfaces}"
  }
}

resource "vsphere_distributed_port_group" "vm" {
  name                            = "DSwitch VM"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"

  vlan_id = 10
}

resource "vsphere_distributed_port_group" "noinet" {
  name                            = "DSwitch NOINET"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"

  vlan_id = 20
}

resource "vsphere_distributed_port_group" "kube" {
  name                            = "DSwitch KUBE"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"

  vlan_id = 30
}

resource "vsphere_distributed_port_group" "general" {
  name                            = "DSwitch GENERAL"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"

  vlan_id = 50
}

resource "vsphere_distributed_port_group" "mgmt" {
  name                            = "DSwitch MGMT"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"

  vlan_id = 100
}
