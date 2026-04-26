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
  ttl     = 3600
}

data "external" "webgw_pip_v6" {
  program = ["${path.module}/ansible-inventory.sh"]
  query = {
    host  = "webgw01"
    query = ".vault_pip_v6_map"
  }
}

resource "cloudflare_record" "webgw_pip_v6" {
  for_each = data.external.webgw_pip_v6.result

  zone_id = cloudflare_zone.this["hb"].id
  name    = "webgw-${each.key}"
  content = each.value
  type    = "AAAA"
  ttl     = 3600
}

resource "cloudflare_record" "webgw_pip_v4" {
  for_each = data.external.webgw_pip_v6.result

  zone_id = cloudflare_zone.this["hb"].id
  name    = "webgw-${each.key}"
  content = data.external.webgw_addresses.result.a
  type    = "A"
  ttl     = 3600
}
