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
  domains   = jsondecode(data.pass_password.domains.full)
  webgw     = format("webgw01.%s", local.domains["hb"])
  webgw_k8s = format("webgw-k8s.%s", local.domains["hb"])
}

resource "cloudflare_zone" "this" {
  for_each = local.domains

  account_id = var.cf_account_id
  zone       = each.value
}

resource "cloudflare_record" "webgw_dv" {
  for_each = toset([
    "admin",
    "cloud",
    local.domains["dv"],
    "gitlab",
    "login",
    "plex",
    "registry",
    "www",
  ])

  zone_id = cloudflare_zone.this["dv"].id
  name    = each.key
  content = local.webgw
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
  content = local.webgw
  type    = "CNAME"
  ttl     = 300
}

resource "cloudflare_record" "romgw" {
  zone_id = cloudflare_zone.this["ti"].id
  name    = "romgw01"
  content = "10.1.0.91"
  type    = "A"
  ttl     = 300
}

resource "cloudflare_record" "local_ti" {
  for_each = toset([
    "ha",
  ])

  zone_id = cloudflare_zone.this["ti"].id
  name    = each.key
  content = cloudflare_record.romgw.hostname
  type    = "CNAME"
  ttl     = 300
}

data "external" "drepi" {
  program = ["${path.module}/ansible-inventory.sh"]
  query = {
    host  = "drepi"
    query = "{\"value\": .ansible_host}"
  }
}

resource "cloudflare_record" "drepi" {
  zone_id = cloudflare_zone.this["hb"].id
  name    = "drepi"
  content = data.external.drepi.result.value
  type    = "A"
  ttl     = 3600
}

resource "cloudflare_record" "webgw_hb" {
  for_each = toset([
    "grafana",
  ])

  zone_id = cloudflare_zone.this["hb"].id
  name    = each.key
  content = local.webgw
  type    = "CNAME"
  ttl     = 300
}

data "external" "talos_cp" {
  program = ["${path.module}/ansible-inventory.sh"]
  query = {
    host  = "talos01"
    query = "{\"value\": .vips.talos.control_plane[0]}"
  }
}

resource "cloudflare_record" "talos_cp" {
  zone_id = cloudflare_zone.this["hb"].id
  name    = "talos"
  content = data.external.talos_cp.result.value
  type    = "A"
  ttl     = 3600
}
