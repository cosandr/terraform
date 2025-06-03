resource "cloudflare_record" "k8s_dv" {
  for_each = toset([
    "audiobookshelf",
    "jellyfin",
    "plex",
  ])

  zone_id = cloudflare_zone.this["dv"].id
  name    = each.key
  content = local.webgw_k8s
  type    = "CNAME"
  ttl     = 300
}
