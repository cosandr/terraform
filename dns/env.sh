#!/usr/bin/env sh

# Consider setting up credential helper instead
# https://developer.hashicorp.com/terraform/cli/config/config-file
# https://developer.hashicorp.com/terraform/plugin/how-terraform-works#plugin-locations
# https://developer.hashicorp.com/terraform/internals/credentials-helpers

export AWS_ACCESS_KEY_ID="$(gopass show -o terraform/state_backblaze_id)"
export AWS_SECRET_ACCESS_KEY="$(gopass show -o terraform/state_backblaze_secret)"
