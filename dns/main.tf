terraform {
  cloud {
    organization = "cosandr"

    workspaces {
      name = "dns"
    }
  }
  required_providers {
    pass = {
      source  = "camptocamp/pass"
      version = "~> 2.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = data.pass_password.cloudflare.password
}

data "pass_password" "cloudflare" {
  path = "ansible/cf_token"
}

data "pass_password" "domains" {
  path = "terraform/domain_map"
}

locals {
  domains    = jsondecode(data.pass_password.domains.full)
  webgw      = format("webgw01.%s", local.domains["hb"]) # TODO: Refer to Hetzner resource
  cf_domains = ["dv", "ti", "cu"]
}

resource "cloudflare_zone" "this" {
  for_each = {
    for k, v in local.domains : k => v if contains(local.cf_domains, k)
  }

  account_id = var.cf_account_id
  zone       = each.value
}

resource "cloudflare_record" "webgw_dv" {
  for_each = toset([
    "admin",
    "cloud",
    local.domains["dv"],
    "gitlab",
    "jellyfin",
    "login",
    "plex",
    "registry",
    "www",
  ])

  zone_id = cloudflare_zone.this["dv"].id
  name    = each.key
  value   = local.webgw
  type    = "CNAME"
  ttl     = 300
}

resource "cloudflare_record" "webgw_ti" {
  for_each = toset([
    "*",
    local.domains["ti"],
  ])

  zone_id = cloudflare_zone.this["ti"].id
  name    = each.key
  value   = local.webgw
  type    = "CNAME"
  ttl     = 300
}

resource "cloudflare_record" "romgw" {
  zone_id = cloudflare_zone.this["ti"].id
  name    = "romgw01"
  value   = "10.1.0.91"
  type    = "A"
  ttl     = 300
}

resource "cloudflare_record" "local_ti" {
  for_each = toset([
    "ha",
    "photoprism",
  ])

  zone_id = cloudflare_zone.this["ti"].id
  name    = each.key
  value   = cloudflare_record.romgw.hostname
  type    = "CNAME"
  ttl     = 300
}
