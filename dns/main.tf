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
    desec = {
      source  = "timofurrer/desec"
      version = "~> 0.6.0"
    }
  }
}

provider "cloudflare" {
  api_token = data.pass_password.cloudflare.password
}

provider "desec" {
  api_token = data.pass_password.desec.password
}

data "pass_password" "cloudflare" {
  path = "terraform/cf_token"
}

data "pass_password" "desec" {
  path = "terraform/desec_token"
}

data "pass_password" "domains" {
  path = "terraform/domain_map"
}

locals {
  desec_keys = ["hb", "dv", "ti"]
  desec_domains = {
    for k, v in local.domains : k => v if contains(local.desec_keys, k)
  }
  domains      = jsondecode(data.pass_password.domains.full)
  webgw        = format("webgw01.%s", local.domains["hb"])
  webgw_docker = cloudflare_dns_record.webgw_pip_v6["docker"].name
  webgw_gitlab = cloudflare_dns_record.webgw_pip_v6["gitlab"].name
  webgw_nginx  = cloudflare_dns_record.webgw_pip_v6["nginx"].name
  webgw_records = {
    gitlab = {
      "A"    = data.external.webgw_addresses.result.a
      "AAAA" = data.external.webgw_pip_v6.result["gitlab"]
    }
    docker = {
      "A"    = data.external.webgw_addresses.result.a
      "AAAA" = data.external.webgw_pip_v6.result["docker"]
    }
    nginx = {
      "A"    = data.external.webgw_addresses.result.a
      "AAAA" = data.external.webgw_pip_v6.result["nginx"]
    }
  }
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

resource "desec_rrset" "ha_ti" {
  domain  = desec_domain.this["ti"].name
  subname = "ha"
  rdata   = ["10.1.0.48"]
  type    = "A"
  ttl     = 3600
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

resource "desec_rrset" "webgw_dv_all" {
  for_each = {
    for record in flatten([
      # Map your target groups to their respective subnames right here
      for target, subnames in {
        gitlab = ["gitlab", "registry"]
        docker = ["abs", "dawarich", "immich", "jellyfin", "plex"]
        nginx  = ["@", "cloud", "www"]
        } : [
        for subname in subnames : [
          # Look up the IPs dynamically based on the current target
          for type, ip in local.webgw_records[target] : {
            key     = "${subname}-${type}"
            subname = subname
            type    = type
            ip      = ip
          }
        ]
      ]
    ]) : record.key => record
  }

  domain  = desec_domain.this["dv"].name
  subname = each.value.subname
  type    = each.value.type
  ttl     = 300
  rdata   = [each.value.ip]
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

resource "desec_rrset" "smtp" {
  domain  = desec_domain.this["hb"].name
  subname = "smtp"
  rdata   = [data.external.webgw_wg.result.value]
  type    = "A"
  ttl     = 3600
}
