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
  type    = "CNAME"
  ttl     = 3600
}

resource "cloudflare_record" "rfc2136_hb_subdomains" {
  for_each = toset([
    "ha",
    "drepi",
    "talos",
  ])

  zone_id = cloudflare_zone.this["hb"].id
  name    = "_acme-challenge.${each.key}"
  value   = format("%s.%s", data.external.rfc2136_domain_map.result["hb"], data.external.rfc2136_domain.result.value)
  type    = "CNAME"
  ttl     = 3600
}
