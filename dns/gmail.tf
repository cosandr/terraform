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
  value    = each.value["value"]
  type     = each.value["type"]
  ttl      = lookup(each.value, "ttl", 3600)
  priority = lookup(each.value, "priority", null)
}

resource "cloudflare_record" "gmail_dv" {
  for_each = local.gmail_records

  zone_id  = cloudflare_zone.this["dv"].id
  name     = lookup(each.value, "name", local.domains["dv"])
  value    = each.value["value"]
  type     = each.value["type"]
  ttl      = lookup(each.value, "ttl", 3600)
  priority = lookup(each.value, "priority", null)
}

resource "cloudflare_record" "gmail_ti" {
  for_each = local.gmail_records

  zone_id  = cloudflare_zone.this["ti"].id
  name     = lookup(each.value, "name", local.domains["ti"])
  value    = each.value["value"]
  type     = each.value["type"]
  ttl      = lookup(each.value, "ttl", 3600)
  priority = lookup(each.value, "priority", null)
}

resource "cloudflare_record" "dkim" {
  for_each = {
    for k, v in local.domains : k => v if contains(local.cf_domains, k)
  }

  zone_id = cloudflare_zone.this[each.key].id
  name    = "google._domainkey"
  value   = data.pass_password.dkim_keys[each.key].password
  type    = "TXT"
  ttl     = 3600
}

resource "hetznerdns_record" "gmail_hb_mx" {
  for_each = {
    for k, v in local.gmail_records : k => v if v["type"] == "MX"
  }

  zone_id = hetznerdns_zone.this["hb"].id
  name    = "@"
  value   = format("%s %s.", each.value["priority"], each.value["value"])
  type    = each.value["type"]
  ttl     = 3600
}

resource "hetznerdns_record" "gmail_hb_spf" {
  zone_id = hetznerdns_zone.this["hb"].id
  name    = "@"
  value   = format("\"%s\"", local.gmail_records["spf"].value)
  type    = "TXT"
  ttl     = 3600
}

resource "hetznerdns_record" "dkim" {
  for_each = {
    for k, v in local.domains : k => v if contains(local.hetzner_domains, k)
  }

  zone_id = hetznerdns_zone.this[each.key].id
  name    = "google._domainkey"
  value   = format("\"%s\"", data.pass_password.dkim_keys[each.key].password)
  type    = "TXT"
  ttl     = 3600

  lifecycle {
    # REMOVE IF KEY CHANGES.
    # Weird behavior where the value gets split in half at some point
    # and terraform wants to change it every time.
    ignore_changes = [value]
  }
}
