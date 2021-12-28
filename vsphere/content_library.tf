resource "vsphere_content_library" "tanzu" {
  name            = "Tanzu"
  storage_backing = [vsphere_nas_datastore.vm.id]
  description     = "Content Library for Tanzu"
}

resource "vsphere_content_library" "ovas" {
  name            = "OVAs"
  storage_backing = [vsphere_nas_datastore.extra.id]
  description     = "Content Library for OVAs"
}

resource "vsphere_content_library_item" "haproxy" {
  name        = "haproxy"
  description = "VMWare HAProxy template"
  library_id  = vsphere_content_library.ovas.id
  file_url    = "https://cdn.haproxy.com/download/haproxy/vsphere/ova/haproxy-v0.2.0.ova"
}
