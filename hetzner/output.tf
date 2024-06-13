output "webgw01_private_ipv4" {
  value = tolist(hcloud_server.webgw01.network)[0].ip
}

output "webgw01_public_ipv4" {
  value = hcloud_server.webgw01.ipv4_address
}

output "webgw01_public_ipv6" {
  value = hcloud_server.webgw01.ipv6_address
}
