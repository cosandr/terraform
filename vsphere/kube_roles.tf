# https://docs.vmware.com/en/VMware-vSphere-Container-Storage-Plug-in/2.0/vmware-vsphere-csp-getting-started/GUID-0AB6E692-AA47-4B6A-8CEA-38B754E16567.html
# https://developer.vmware.com/samples/7400/create-csi-driver-vcenter-roles

resource "vsphere_role" "cns_datastore" {
  name = "CNS-DATASTORE"
  role_privileges = [
    "Datastore.FileManagement",
    "System.Anonymous",
    "System.Read",
    "System.View",
  ]

  # Workaround bug where System.* is not detected and added every time
  lifecycle {
    ignore_changes = [role_privileges]
  }
}

# Allows vSAN datastore management.
# resource "vsphere_role" "cns_host_config_storage" {
#   name = "CNS-HOST-CONFIG-STORAGE"
#   role_privileges = [
#     "Host.Config.Storage",
#     "System.Anonymous",
#     "System.Read",
#     "System.View",
#   ]
# }

resource "vsphere_role" "cns_vm" {
  name = "CNS-VM"
  role_privileges = [
    "System.Anonymous",
    "System.Read",
    "System.View",
    "VirtualMachine.Config.AddExistingDisk",
    "VirtualMachine.Config.AddRemoveDevice",
  ]

  # Workaround bug where System.* is not detected and added every time
  lifecycle {
    ignore_changes = [role_privileges]
  }
}

resource "vsphere_role" "cns_search_and_spbm" {
  name = "CNS-SEARCH-AND-SPBM"
  role_privileges = [
    "Cns.Searchable",
    "StorageProfile.View",
    "System.Anonymous",
    "System.Read",
    "System.View",
  ]

  # Workaround bug where System.* is not detected and added every time
  lifecycle {
    ignore_changes = [role_privileges]
  }
}

data "vsphere_role" "read_only" {
  label = "Read-only"
}

# Create kube-csi user manually

resource "vsphere_entity_permissions" "csi_datastore" {
  entity_id   = vsphere_nas_datastore.vm.id
  entity_type = "Datastore"
  permissions {
    user_or_group = "vsphere.local\\kube-csi"
    propagate     = false
    is_group      = false
    role_id       = vsphere_role.cns_datastore.id
  }
}

resource "vsphere_entity_permissions" "csi_hosts" {
  count       = length(data.vsphere_host.host)
  entity_id   = data.vsphere_host.host[count.index].id
  entity_type = "HostSystem"
  permissions {
    user_or_group = "vsphere.local\\kube-csi"
    propagate     = false
    is_group      = false
    role_id       = data.vsphere_role.read_only.id
  }
}

resource "vsphere_entity_permissions" "csi_datacenter" {
  entity_id   = data.vsphere_datacenter.home.id
  entity_type = "Datacenter"
  permissions {
    user_or_group = "vsphere.local\\kube-csi"
    propagate     = false
    is_group      = false
    role_id       = data.vsphere_role.read_only.id
  }
}

resource "vsphere_entity_permissions" "csi_root" {
  entity_id   = "group-d1"
  entity_type = "Folder"
  permissions {
    user_or_group = "vsphere.local\\kube-csi"
    propagate     = false
    is_group      = false
    role_id       = vsphere_role.cns_search_and_spbm.id
  }

  # Workaround bug where it tries to delete all permissions
  lifecycle {
    ignore_changes = [permissions]
  }
}

resource "vsphere_entity_permissions" "kube_vms_master" {
  entity_id   = vsphere_virtual_machine.kube_master.id
  entity_type = "VirtualMachine"
  permissions {
    user_or_group = "vsphere.local\\kube-csi"
    propagate     = false
    is_group      = false
    role_id       = vsphere_role.cns_vm.id
  }
}

resource "vsphere_entity_permissions" "kube_vms_worker" {
  count       = length(vsphere_virtual_machine.kube_worker)
  entity_id   = vsphere_virtual_machine.kube_worker[count.index].id
  entity_type = "VirtualMachine"
  permissions {
    user_or_group = "vsphere.local\\kube-csi"
    propagate     = false
    is_group      = false
    role_id       = vsphere_role.cns_vm.id
  }
}
