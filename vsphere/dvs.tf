resource "vsphere_distributed_virtual_switch" "dvs" {
  name          = "DSwitch"
  datacenter_id = "${data.vsphere_datacenter.home.id}"

  uplinks         = ["uplink1", "uplink2", "uplink3", "uplink4"]
  active_uplinks  = ["uplink1", "uplink2"]
  standby_uplinks = ["uplink3", "uplink4"]

  host {
    host_system_id = "${data.vsphere_host.host.0.id}"
    devices        = "${var.dvs_network_interfaces}"
  }
}

resource "vsphere_distributed_port_group" "vm" {
  name                            = "VM"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"

  vlan_id = 10
}

resource "vsphere_distributed_port_group" "noinet" {
  name                            = "NOINET"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"

  vlan_id = 20
}

resource "vsphere_distributed_port_group" "general" {
  name                            = "GENERAL"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"

  vlan_id = 50
}

resource "vsphere_distributed_port_group" "mgmt" {
  name                            = "MGMT"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"

  vlan_id = 100
}

resource "vsphere_distributed_port_group" "kube" {
  name                            = "KUBE"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"

  vlan_id = 233
}

resource "vsphere_distributed_port_group" "trunk" {
  name                            = "0-Trunk"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"

  type = "ephemeral"
  auto_expand = false

  vlan_range {
    min_vlan = 10
    max_vlan = 10
  }

  vlan_range {
    min_vlan = 20
    max_vlan = 20
  }

  vlan_range {
    min_vlan = 50
    max_vlan = 50
  }

  vlan_range {
    min_vlan = 100
    max_vlan = 100
  }
}
