terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.0"
    }
    mikrotik = {
      source  = "ddelnano/mikrotik"
      version = "~> 0.8"
    }
    pass = {
      source  = "mecodia/pass"
      version = "~> 3.0"
    }
  }
  backend "pg" {}
}

locals {
  mikrotik_user     = data.pass_password.mikrotik_user.password
  mikrotik_password = data.pass_password.mikrotik_password.password
  vsphere_server    = data.pass_password.vsphere_server.password
  vsphere_password  = data.pass_password.vsphere_password.password
  ipv4_gateways = {
    vm   = cidrhost(var.vm_net_space, 1),
    mgmt = cidrhost(var.mgmt_net_space, 1),
  }
}

provider "mikrotik" {
  host     = var.mikrotik_api_url
  username = local.mikrotik_user
  password = local.mikrotik_password
  tls      = true
  insecure = true
}

provider "vsphere" {
  user           = var.vsphere_user
  password       = local.vsphere_password
  vsphere_server = local.vsphere_server

  allow_unverified_ssl = true
}

data "vsphere_datacenter" "home" {
  name = "Home"
}

data "vsphere_host" "host" {
  count         = length(var.esxi_hosts)
  name          = var.esxi_hosts[count.index]
  datacenter_id = data.vsphere_datacenter.home.id
}

data "vsphere_datastore" "vm" {
  name          = "TrueNAS-VM"
  datacenter_id = data.vsphere_datacenter.home.id
}

data "vsphere_datastore" "tank" {
  name          = "TrueNAS-Tank"
  datacenter_id = data.vsphere_datacenter.home.id
}

data "vsphere_resource_pool" "home" {
  name          = "Home/Resources"
  datacenter_id = data.vsphere_datacenter.home.id
}

data "vsphere_storage_policy" "encryption" {
  name = "VM Encryption Policy"
}

resource "vsphere_tag" "autostart" {
  name        = "autostart"
  category_id = vsphere_tag_category.meta.id
  description = "VM should be autostarted"
}

resource "vsphere_folder" "services" {
  path          = "Services"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.home.id
}
