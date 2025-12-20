terraform {
  backend "s3" {
    profile = "backblaze"
    key     = "rgw"
    bucket  = "cosandr-terraform"
    region  = "eu-north-1"

    skip_s3_checksum            = true
    skip_requesting_account_id  = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
}

# https://docs.ceph.com/en/squid/radosgw/iam/
provider "aws" {
  profile = "rgwroot"

  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
}

# Cannot use aws_caller_identity
data "pass_password" "account_id" {
  path = "rgw/account_id"
}

data "pass_password" "pgp_key" {
  # gpg --export 273D94492E01567B | gopass cat terraform/rgw_pgp_key
  path = "terraform/rgw_pgp_key"
}

locals {
  account_id = data.pass_password.account_id.password
  pgp_key    = data.pass_password.pgp_key.body
}

output "account_id" {
  value = local.account_id
}
