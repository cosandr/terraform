output "cloudgw_private_ipv4" {
  value = tolist(hcloud_server.cloudgw.network)[0].ip
}

output "cloudgw_public_ipv4" {
  value = hcloud_server.cloudgw.ipv4_address
}

output "cloudgw_public_ipv6" {
  value = hcloud_server.cloudgw.ipv6_address
}
