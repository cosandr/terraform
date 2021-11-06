resource "vsphere_folder" "folder" {
  for_each = toset([
    "Permanent",
    "templates",
    "Backend"
  ])
  path          = each.key
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
