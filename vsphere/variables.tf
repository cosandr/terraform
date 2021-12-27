variable "vsphere_user" {
    default = "administrator@vsphere.local"
}

variable "vsphere_password" {
    type = string
    sensitive = true
}

variable "vsphere_server" {
    type = string
}

variable "vm_net_space" {
    type = string
    default = "10.0.10.0/24"
}

variable "esxi_hosts" {
  default = [
    "10.0.100.5",
  ]
}

variable "dvs_network_interfaces" {
  default = [
    "vmnic0",
    "vmnic1",
  ]
}
