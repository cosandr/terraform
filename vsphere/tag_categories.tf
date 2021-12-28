resource "vsphere_tag_category" "ansible_group" {
  name        = "ansible_group"
  cardinality = "MULTIPLE"
  description = "Tags read by Ansible"

  associable_types = ["VirtualMachine"]
}

resource "vsphere_tag_category" "storage" {
  name        = "storage"
  cardinality = "MULTIPLE"
  description = "Tags used by storage policies"

  associable_types = ["Datastore"]
}
