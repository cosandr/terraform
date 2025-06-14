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

resource "cloudflare_record" "gmail_cu" {
  for_each = local.gmail_records

  zone_id  = cloudflare_zone.this["cu"].id
  name     = lookup(each.value, "name", local.domains["cu"])
  content  = each.value["value"]
  type     = each.value["type"]
  ttl      = lookup(each.value, "ttl", 3600)
  priority = lookup(each.value, "priority", null)
}

resource "cloudflare_record" "gmail_dv" {
  for_each = local.gmail_records

  zone_id  = cloudflare_zone.this["dv"].id
  name     = lookup(each.value, "name", local.domains["dv"])
  content  = each.value["value"]
  type     = each.value["type"]
  ttl      = lookup(each.value, "ttl", 3600)
  priority = lookup(each.value, "priority", null)
}

resource "cloudflare_record" "gmail_ti" {
  for_each = local.gmail_records

  zone_id  = cloudflare_zone.this["ti"].id
  name     = lookup(each.value, "name", local.domains["ti"])
  content  = each.value["value"]
  type     = each.value["type"]
  ttl      = lookup(each.value, "ttl", 3600)
  priority = lookup(each.value, "priority", null)
}

resource "cloudflare_record" "gmail_hb" {
  for_each = local.gmail_records

  zone_id  = cloudflare_zone.this["hb"].id
  name     = lookup(each.value, "name", local.domains["hb"])
  content  = each.value["value"]
  type     = each.value["type"]
  ttl      = lookup(each.value, "ttl", 3600)
  priority = lookup(each.value, "priority", null)
}

resource "cloudflare_record" "dkim" {
  for_each = local.domains

  zone_id = cloudflare_zone.this[each.key].id
  name    = "google._domainkey"
  content = data.pass_password.dkim_keys[each.key].password
  type    = "TXT"
  ttl     = 3600
}

resource "cloudflare_record" "dmarc" {
  for_each = local.domains

  zone_id = cloudflare_zone.this[each.key].id
  name    = "_dmarc"
  # https://support.google.com/a/answer/2466580?hl=en#zippy=%2Cdmarc-record-tag-definitions-and-values
  content = "v=DMARC1; p=none; rua=mailto:dmarc@${each.value}; pct=100; adkim=s; aspf=s"
  type    = "TXT"
  ttl     = 3600
}
