data "pass_password" "dkim_keys" {
  for_each = toset(keys(local.domains))

  path = "gmail/${each.key}_dkim_key"
}

locals {
  # Map works best with for_each
  gmail_records = {
    mx_primary = {
      type     = "MX",
      value    = "aspmx.l.google.com",
      priority = 1,
    },
    mx_alt1 = {
      type     = "MX",
      value    = "alt1.aspmx.l.google.com",
      priority = 5,
    },
    mx_alt2 = {
      type     = "MX",
      value    = "alt2.aspmx.l.google.com",
      priority = 5,
    },
    mx_alt3 = {
      type     = "MX",
      value    = "alt3.aspmx.l.google.com",
      priority = 10,
    },
    mx_alt4 = {
      type     = "MX",
      value    = "alt4.aspmx.l.google.com",
      priority = 10,
    },
    spf = {
      type  = "TXT",
      value = "v=spf1 include:_spf.google.com ~all",
    },
  }
}

resource "cloudflare_dns_record" "gmail_cu" {
  for_each = local.gmail_records

  zone_id  = cloudflare_zone.this["cu"].id
  name     = lookup(each.value, "name", local.domains["cu"])
  content  = each.value["value"]
  type     = each.value["type"]
  ttl      = lookup(each.value, "ttl", 3600)
  priority = lookup(each.value, "priority", null)
}

resource "cloudflare_dns_record" "dkim" {
  for_each = local.cf_domains

  zone_id = cloudflare_zone.this[each.key].id
  name    = "google._domainkey"
  content = data.pass_password.dkim_keys[each.key].password
  type    = "TXT"
  ttl     = 3600
}

resource "cloudflare_dns_record" "dmarc" {
  for_each = local.cf_domains

  zone_id = cloudflare_zone.this[each.key].id
  name    = "_dmarc"
  content = "v=DMARC1; p=none; rua=mailto:dmarc@${each.value}; pct=100; adkim=s; aspf=s"
  type    = "TXT"
  ttl     = 3600
}

resource "desec_rrset" "gmail_mx" {
  for_each = local.desec_domains

  domain  = desec_domain.this[each.key].name
  subname = "@"
  type    = "MX"
  ttl     = 3600
  rdata = [
    "1 aspmx.l.google.com.",
    "5 alt1.aspmx.l.google.com.",
    "5 alt2.aspmx.l.google.com.",
    "10 alt3.aspmx.l.google.com.",
    "10 alt4.aspmx.l.google.com.",
  ]
}

resource "desec_rrset" "gmail_spf" {
  for_each = local.desec_domains

  domain  = desec_domain.this[each.key].name
  subname = "@"
  type    = "TXT"
  ttl     = 3600
  rdata   = ["\"v=spf1 include:_spf.google.com ~all\""]
}

resource "desec_rrset" "dkim" {
  for_each = local.desec_domains

  domain  = desec_domain.this[each.key].name
  subname = "google._domainkey"
  type    = "TXT"
  ttl     = 3600
  # Max 255 chars
  rdata = [
    "\"${join("\" \"", regexall(".{1,255}", data.pass_password.dkim_keys[each.key].password))}\""
  ]
}

resource "desec_rrset" "dmarc" {
  for_each = local.desec_domains

  domain  = desec_domain.this[each.key].name
  subname = "_dmarc"
  type    = "TXT"
  ttl     = 3600
  rdata   = ["\"v=DMARC1; p=none; rua=mailto:dmarc@${local.desec_domains[each.key]}; pct=100; adkim=s; aspf=s\""]
}
