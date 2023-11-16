terraform {
  backend "s3" {
    key      = "dns"
    bucket   = "cosandr-terraform"
    endpoint = "https://s3.eu-central-003.backblazeb2.com"
    region   = "eu-north-1"

    skip_s3_checksum            = true
    skip_requesting_account_id  = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
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
    hetznerdns = {
      source  = "timohirt/hetznerdns"
      version = "~> 2.2"
    }
    ansiblevault = {
      source  = "MeilleursAgents/ansiblevault"
      version = "~> 2.3"
    }
  }
}

provider "cloudflare" {
  api_token = data.pass_password.cloudflare.password
}

provider "hetznerdns" {
  apitoken = data.pass_password.hetzner.password
}

provider "ansiblevault" {
  vault_pass  = data.pass_password.ansible_vault.password
  root_folder = "../../ansible"
}

data "pass_password" "cloudflare" {
  path = "ansible/cf_token"
}

data "pass_password" "hetzner" {
  path = "terraform/hetzner_token"
}

data "pass_password" "domains" {
  path = "terraform/domain_map"
}

data "pass_password" "ansible_vault" {
  path = "ansible/vault_pass"
}

locals {
  domains         = jsondecode(data.pass_password.domains.full)
  webgw           = format("webgw01.%s", local.domains["hb"]) # TODO: Refer to Hetzner resource
  cf_domains      = ["dv", "ti", "cu"]
  hetzner_domains = ["hb"]
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

resource "hetznerdns_zone" "this" {
  for_each = {
    for k, v in local.domains : k => v if contains(local.hetzner_domains, k)
  }

  name = each.value
  ttl  = 86400
}

resource "hetznerdns_record" "drepi" {
  zone_id = hetznerdns_zone.this["hb"].id
  name    = "drepi"
  # This is absolutely disgusting, but I couldn't find a good solution
  value = regex("(?m)^drepi.*ansible_host=\"?([^ \"]+)?", file("../../ansible/inventory/hosts"))[0]
  type  = "A"
  ttl   = 3600
}

resource "hetznerdns_record" "webgw_hb" {
  for_each = toset([
    "grafana",
  ])

  zone_id = hetznerdns_zone.this["hb"].id
  name    = each.key
  value   = format("%s.", local.webgw)
  type    = "CNAME"
  ttl     = 300
}
