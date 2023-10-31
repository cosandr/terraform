data "ansiblevault_path" "webgw01_a" {
  # No idea why I need only one ../ here
  path = "../ansible/inventory/host_vars/webgw01/vault.yml"
  key  = "vault_ansible_host"
}

data "ansiblevault_path" "webgw01_aaaa" {
  path = "../ansible/inventory/host_vars/webgw01/vault.yml"
  key  = "vault_ansible_host6"
}

resource "hetznerdns_record" "webgw01" {
  for_each = {
    a    = data.ansiblevault_path.webgw01_a.value
    aaaa = data.ansiblevault_path.webgw01_aaaa.value
  }

  zone_id = hetznerdns_zone.this["hb"].id
  name    = "webgw01"
  value   = each.value
  type    = upper(each.key)
}
