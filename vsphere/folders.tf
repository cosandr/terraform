resource "vsphere_folder" "folder" {
  for_each = toset([
    "Backend",
    "Permanent",
    "PostgreSQL",
    "templates",
    "Windows"
  ])
  path          = each.key
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.home.id
}
