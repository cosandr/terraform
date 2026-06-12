terraform {
  backend "s3" {
    key    = "dns"
    bucket = "cosandr-terraform"
    endpoints = {
      s3 = "https://s3.eu-central-003.backblazeb2.com"
    }
    region = "eu-north-1"

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
      version = "~> 5.0"
    }
  }
}

provider "cloudflare" {
  api_token = data.pass_password.cloudflare.password
}

data "pass_password" "cloudflare" {
  path = "terraform/cf_token"
}

data "pass_password" "domains" {
  path = "terraform/domain_map"
}

locals {
  domains      = jsondecode(data.pass_password.domains.full)
  webgw        = format("webgw01.%s", local.domains["hb"])
  webgw_docker = cloudflare_dns_record.webgw_pip_v6["docker"].name
  webgw_gitlab = cloudflare_dns_record.webgw_pip_v6["gitlab"].name
  webgw_nginx  = cloudflare_dns_record.webgw_pip_v6["nginx"].name
}

resource "cloudflare_zone" "this" {
  for_each = local.domains

  name = each.value
  account = {
    id = var.cf_account_id
  }
}

resource "cloudflare_dns_record" "ha_ti" {
  zone_id = cloudflare_zone.this["ti"].id
  name    = "ha"
  content = "10.1.0.48"
  type    = "A"
  ttl     = 300
}

resource "cloudflare_dns_record" "webgw_dv" {
  for_each = toset([
    "cloud",
    "www",
    local.domains["dv"],
  ])

  zone_id = cloudflare_zone.this["dv"].id
  name    = each.key
  content = local.webgw_nginx
  type    = "CNAME"
  ttl     = 300
}

resource "cloudflare_dns_record" "webgw_gitlab" {
  for_each = toset([
    "gitlab",
    "registry",
  ])

  zone_id = cloudflare_zone.this["dv"].id
  name    = each.key
  content = local.webgw_gitlab
  type    = "CNAME"
  ttl     = 300
}

resource "cloudflare_dns_record" "webgw_docker" {
  for_each = toset([
    "abs",
    "dawarich",
    "immich",
    "jellyfin",
    "plex",
  ])

  zone_id = cloudflare_zone.this["dv"].id
  name    = each.key
  content = local.webgw_docker
  type    = "CNAME"
  ttl     = 300
}

data "external" "webgw_wg" {
  program = ["${path.module}/ansible-inventory.sh"]
  query = {
    host  = "webgw01"
    query = "{\"value\": .wireguard_ip}"
  }
}

resource "cloudflare_dns_record" "smtp" {
  zone_id = cloudflare_zone.this["hb"].id
  name    = "smtp"
  content = data.external.webgw_wg.result.value
  type    = "A"
  ttl     = 3600
}
