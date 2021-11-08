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

data "vsphere_datacenter" "dc" {
  name = "Home"
}

data "vsphere_datastore" "tn_ssd" {
  name          = "TrueNAS-SSD"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "slb" {
  name          = "10.0.100.5/Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "vlan10" {
  name          = "VLAN10"
  datacenter_id = data.vsphere_datacenter.dc.id
}
