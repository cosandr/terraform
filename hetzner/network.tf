resource "hcloud_network" "this" {
  name     = "main"
  ip_range = local.net_cidr
}

resource "hcloud_network_subnet" "webgw" {
  network_id   = hcloud_network.this.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = cidrsubnet(local.net_cidr, 4, 0)
}

resource "hcloud_primary_ip" "webgw" {
  for_each = toset(["ipv4", "ipv6"])

  name          = "webgw-${each.key}"
  type          = each.key
  assignee_type = "server"

  auto_delete       = false
  delete_protection = true

  lifecycle {
    prevent_destroy = true
  }
}
