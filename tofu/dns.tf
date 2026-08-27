locals {
  gh_pages_a_records = ["185.199.108.153", "185.199.109.153", "185.199.110.153", "185.199.111.153"]
  gh_pages_aaaa_records = ["2606:50c0:8000::153", "2606:50c0:8001::153", "2606:50c0:8002::153", "2606:50c0:8003::153"]
}

resource "namecheap_domain_host_record" "github_pages" {
  domain   = "soulhatch.band"
  hostname = "_github-pages-challenge-Weastie"
  type     = "TXT"
  address  = "b09d73d8dd80b25a6ee312669be823"
}

resource "namecheap_domain_host_record" "github_pages_a" {
  for_each = toset(local.gh_pages_a_records)
  domain   = "soulhatch.band"
  hostname = "@"
  type     = "A"
  address  = each.key
}

resource "namecheap_domain_host_record" "github_pages_aaaa" {
  for_each = toset(local.gh_pages_aaaa_records)
  domain   = "soulhatch.band"
  hostname = "@"
  type     = "AAAA"
  address  = each.key
}
