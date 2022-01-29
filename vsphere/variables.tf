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

variable "mikrotik_api_url" {
  default = "10.0.50.1:8729"
}

variable "mikrotik_user" {
    type = string
}

variable "mikrotik_password" {
    type = string
    sensitive = true
}

variable "vm_net_space" {
    type = string
    default = "10.0.10.0/24"
}

variable "esxi_hosts" {
  default = [
    "slb.esxi.hlab.no",
  ]
}

variable "dvs_network_interfaces" {
  default = [
    "vmnic2",
    "vmnic3",
  ]
}

variable "truenas_ip" {
    type = string
    default = "172.16.200.20"
}
