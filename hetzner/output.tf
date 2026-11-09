output "cloudgw_public_ipv4" {
  value = hcloud_server.cloudgw.ipv4_address
}

output "cloudgw_public_ipv6" {
  value = hcloud_server.cloudgw.ipv6_address
}
