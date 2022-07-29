# Required
variable "datacenter_id" {
}

variable "datastore_id" {
}

variable "name" {
}

variable "resource_pool_id" {
}

variable "template_name" {
}

# Optional
variable "add_mikrotik_dns" {
  type = bool
  default = true
}

variable "enable_disk_uuid" {
  type = bool
  default = false
}

variable "extra_config" {
  type = map
  default = null
}

variable "cores" {
  type = number
  default = 4
}

variable "data_disks" {
  type = list(map(string))
  default = []
}

variable "domain" {
  default = "vm.hlab.no"
}

variable "folder" {
  default = null
}

variable "memory" {
  type = number
  default = 4096
}

variable "os_disk_size" {
  type = number
  default = null
}

variable "storage_policy_id" {
  default = null
}

variable "tags" {
  default = null
  description = "Optional list of tag IDs to apply"
}

variable "host_name" {
  default = null
}

variable "networks" {
  type = list(map(string))
  default = []
}

variable "ipv4_gateway" {
  default = null
}

variable "ipv6_gateway" {
  default = null
}

variable "nested_hv_enabled" {
  type = bool
  default = false
}

variable "cpu_hot_add_enabled" {
  default = false
}

variable "cpu_hot_remove_enabled" {
  default = false
}

variable "memory_hot_add_enabled" {
  default = false
}
