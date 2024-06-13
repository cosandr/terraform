terraform {
  backend "s3" {
    key      = "hetzner"
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
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}

provider "hcloud" {
  token = data.pass_password.hcloud.password
}

data "pass_password" "hcloud" {
  path = "terraform/hetzner_token"
}

locals {
  net_cidr = "10.6.9.0/24"
}
