
resource "namecheap_domain_host_record" "soulhatch_listmonk" {
  domain   = "soulhatch.band"
  hostname = "listmonk"
  type     = "A"
  address  = "127.0.0.1"
  ttl = 300

  lifecycle {
    ignore_changes = [
      address # Ignores drift due to DDNS updates
    ]
  }
}

