data "pass_password" "mikrotik_user" {
  path = "terraform/mikrotik_user"
}

data "pass_password" "mikrotik_password" {
  path = "terraform/mikrotik_password"
}

data "pass_password" "vsphere_server" {
  path = "terraform/vsphere_server"
}

data "pass_password" "vsphere_password" {
  path = "terraform/vsphere_password"
}
