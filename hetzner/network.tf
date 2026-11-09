resource "hcloud_network" "this" {
  name     = "main"
  ip_range = local.net_cidr
}

resource "hcloud_network_subnet" "cloudgw" {
  network_id   = hcloud_network.this.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = cidrsubnet(local.net_cidr, 4, 0)
}

resource "hcloud_primary_ip" "cloudgw" {
  for_each = toset(["ipv4", "ipv6"])

  name          = "cloudgw-${each.key}"
  type          = each.key
  assignee_type = "server"

  auto_delete       = false
  delete_protection = true

  lifecycle {
    prevent_destroy = true
  }
}
