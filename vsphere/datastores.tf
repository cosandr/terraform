resource "vsphere_nas_datastore" "vm" {
  name            = "TrueNAS-VM"
  host_system_ids = data.vsphere_host.host.*.id

  type          = "NFS41"
  security_type = "AUTH_SYS"
  remote_hosts  = ["${var.truenas_ip}"]
  remote_path   = "/mnt/ssd/vm"
}

resource "vsphere_nas_datastore" "extra" {
  name            = "TrueNAS-Extra"
  host_system_ids = data.vsphere_host.host.*.id

  type          = "NFS41"
  security_type = "AUTH_SYS"
  remote_hosts  = ["${var.truenas_ip}"]
  remote_path   = "/mnt/extra/esxi"
}

resource "vsphere_nas_datastore" "disk-images" {
  name            = "TrueNAS-Disk-Images"
  host_system_ids = data.vsphere_host.host.*.id

  type          = "NFS41"
  security_type = "AUTH_SYS"
  remote_hosts  = ["${var.truenas_ip}"]
  remote_path   = "/mnt/tank/archive/disk-images"
}
