terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      version = "~> 2.0"
    }
  }
  backend "pg" {}
}

provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  allow_unverified_ssl = true
}

data "vsphere_datacenter" "home" {
  name = "Home"
}

data "vsphere_host" "host" {
  count         = "${length(var.esxi_hosts)}"
  name          = "${var.esxi_hosts[count.index]}"
  datacenter_id = "${data.vsphere_datacenter.home.id}"
}

data "vsphere_datastore" "vm" {
  name          = "TrueNAS-VM"
  datacenter_id = data.vsphere_datacenter.home.id
}

data "vsphere_datastore" "extra" {
  name          = "TrueNAS-Extra"
  datacenter_id = data.vsphere_datacenter.home.id
}

data "vsphere_resource_pool" "home" {
  name          = "Home/Resources"
  datacenter_id = data.vsphere_datacenter.home.id
}
