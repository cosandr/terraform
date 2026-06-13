# Create in UI, import afterwards (so value isn't stored in state)
# Get tokens with
# curl -s --header "Authorization: Token $(gopass show -o terraform/desec_token)" https://desec.io/api/v1/auth/tokens/ | jq
# import {
#   to = desec_token.this["lego_ha"]
#   id = ""
# }

resource "desec_domain" "this" {
  for_each = local.desec_domains

  name = each.value
}

resource "desec_token" "this" {
  for_each = toset([
    "lego_ha_ti",
    "lego_ha",
    "lego_webgw",
  ])
  name = each.value
}

# Check policies
# curl -s --header "Authorization: Token $(gopass show -o terraform/desec_token)" https://desec.io/api/v1/auth/tokens/{id}/policies/rrsets/| jq

resource "desec_token_policy" "default" {
  for_each = desec_token.this

  token_id   = each.value.id
  perm_write = false
}

resource "desec_token_policy" "lego_webgw" {
  for_each = desec_domain.this

  token_id   = desec_token.this["lego_webgw"].id
  domain     = each.value.name
  subname    = "_acme-challenge"
  type       = "TXT"
  perm_write = true

  depends_on = [desec_token_policy.default["lego_webgw"]]
}

resource "desec_token_policy" "lego_ha" {
  token_id   = desec_token.this["lego_ha"].id
  domain     = local.domains["hb"]
  subname    = "_acme-challenge.ha"
  type       = "TXT"
  perm_write = true

  depends_on = [desec_token_policy.default["lego_ha"]]
}

resource "desec_token_policy" "lego_ha_ti" {
  token_id   = desec_token.this["lego_ha_ti"].id
  domain     = local.domains["ti"]
  subname    = "_acme-challenge.ha"
  type       = "TXT"
  perm_write = true

  depends_on = [desec_token_policy.default["lego_ha_ti"]]
}
