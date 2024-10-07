data "external" "webgw_addresses" {
  program = ["${path.module}/ansible-inventory.sh"]
  query = {
    host  = "webgw01"
    query = "{\"a\": .vault_ansible_host, \"aaaa\": .vault_ansible_host6}"
  }
}

resource "cloudflare_record" "webgw01" {
  for_each = data.external.webgw_addresses.result

  zone_id = cloudflare_zone.this["hb"].id
  name    = "webgw01"
  content = each.value
  type    = upper(each.key)
  ttl     = 86400
}
