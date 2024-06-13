resource "hcloud_server" "webgw01" {
  name        = "webgw01"
  image       = "rocky-9"
  server_type = "cax11"
  location    = "hel1"

  delete_protection        = true
  rebuild_protection       = true
  shutdown_before_deletion = true

  ssh_keys = [hcloud_ssh_key.desktop.id, hcloud_ssh_key.laptop.id]

  public_net {
    ipv4_enabled = true
    ipv4         = hcloud_primary_ip.webgw["ipv4"].id
    ipv6_enabled = true
    ipv6         = hcloud_primary_ip.webgw["ipv6"].id
  }

  network {
    network_id = hcloud_network.this.id
    ip         = cidrhost(hcloud_network_subnet.webgw.ip_range, 2)
    alias_ips  = []
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [ssh_keys]
  }
}
