#!/usr/bin/env sh

# Consider setting up credential helper instead
# https://developer.hashicorp.com/terraform/cli/config/config-file
# https://developer.hashicorp.com/terraform/plugin/how-terraform-works#plugin-locations
# https://developer.hashicorp.com/terraform/internals/credentials-helpers

export TF_TOKEN_app_terraform_io="$(gopass show -o terraform/cloud_token)"
