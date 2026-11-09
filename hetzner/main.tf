terraform {
  backend "s3" {
    key    = "hetzner"
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

resource "hcloud_ssh_key" "desktop" {
  name       = "andrei@desktop"
  public_key = file("~/.local/share/chezmoi/private_dot_ssh/private_desktop_ed25519.pub")
}

resource "hcloud_ssh_key" "laptop" {
  name       = "andrei@laptop"
  public_key = file("~/.local/share/chezmoi/private_dot_ssh/private_laptop_ed25519.pub")
}

resource "hcloud_ssh_key" "mac" {
  name       = "andrei@mac"
  public_key = file("~/.local/share/chezmoi/private_dot_ssh/private_mac_ed25519.pub")
}

resource "hcloud_primary_ip" "cloudgw" {
  for_each = toset(["ipv4", "ipv6"])

  name          = "cloudgw-${each.key}"
  type          = each.key
  assignee_type = "server"

  auto_delete       = false
  delete_protection = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "hcloud_server" "cloudgw" {
  name        = "cloudgw"
  image       = "rocky-9"
  server_type = "cax11"

  delete_protection        = true
  rebuild_protection       = true
  shutdown_before_deletion = true

  ssh_keys = [hcloud_ssh_key.desktop.id, hcloud_ssh_key.laptop.id, hcloud_ssh_key.mac.id]

  public_net {
    ipv4_enabled = true
    ipv4         = hcloud_primary_ip.cloudgw["ipv4"].id
    ipv6_enabled = true
    ipv6         = hcloud_primary_ip.cloudgw["ipv6"].id
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [ssh_keys]
  }
}
