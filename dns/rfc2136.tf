data "external" "rfc2136_domain" {
  program = ["${path.module}/ansible-inventory.sh"]
  query = {
    host  = "webgw01"
    query = "{\"value\": .vault_rfc2136_domain}"
  }
}

data "external" "rfc2136_domain_map" {
  program = ["${path.module}/ansible-inventory.sh"]
  query = {
    host  = "webgw01"
    query = ".vault_rfc2136_domain_map"
  }
}

resource "cloudflare_record" "rfc2136" {
  for_each = data.external.rfc2136_domain_map.result

  zone_id = cloudflare_zone.this[each.key].id
  name    = "_acme-challenge"
  value   = "${each.value}.${data.external.rfc2136_domain.result.value}"
  type    = "TXT"
  ttl     = 3600
}
