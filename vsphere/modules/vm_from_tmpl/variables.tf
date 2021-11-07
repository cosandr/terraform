# Required
variable "datacenter_id" {
}

variable "datastore_id" {
}

variable "name" {
}

variable "network_id" {
}

variable "resource_pool_id" {
}

variable "template_name" {
}

variable "vm_net" {
  description = "Network in CIDR format"
}

variable "ip_address" {
  type = number
  description = "IP address, only the last octet"
}

# Optional
variable "cores" {
  type = number
  default = 4
}

variable "data_disk_size" {
  type = number
  default = 50
}

variable "data_disks" {
  type = number
  default = 0
}

variable "domain" {
  default = "vm.local"
}

variable "folder" {
  default = null
}

variable "memory" {
  type = number
  default = 4096
}

variable "tags" {
  default = null
  description = "Optional list of tag IDs to apply"
}
