# Run with cloudflare.tfvars, so the hostnames checked are the ones
# that get applied.
mock_provider "cloudflare" {
  mock_resource "cloudflare_zero_trust_tunnel_cloudflared" {
    defaults = {
      id = "00000000-0000-0000-0000-000000000000"
    }
  }
}

run "tunnel_is_remotely_managed" {
  command = plan

  assert {
    condition     = cloudflare_zero_trust_tunnel_cloudflared.this.config_src == "cloudflare"
    error_message = "cloudflared reads its rules from Cloudflare, so the tunnel must be remotely managed"
  }
}

run "every_hostname_is_routed_and_has_a_record" {
  command = apply

  assert {
    condition     = length(cloudflare_dns_record.this) == length(var.hostnames)
    error_message = "Each hostname needs a CNAME"
  }

  assert {
    condition     = alltrue([for r in cloudflare_dns_record.this : r.type == "CNAME" && r.proxied && r.content == "00000000-0000-0000-0000-000000000000.cfargotunnel.com"])
    error_message = "Each record must be a proxied CNAME to the tunnel"
  }

  assert {
    condition     = tolist([for i in cloudflare_zero_trust_tunnel_cloudflared_config.this.config.ingress : i.hostname if i.hostname != null]) == var.hostnames
    error_message = "Each hostname needs an ingress rule"
  }
}

run "gateway_certificate_is_verified" {
  command = plan

  assert {
    condition     = alltrue([for i in cloudflare_zero_trust_tunnel_cloudflared_config.this.config.ingress : i.origin_request.origin_server_name == i.hostname if i.hostname != null])
    error_message = "cloudflared must send each hostname as SNI so the gateway's certificate verifies"
  }
}

run "unknown_hostnames_get_a_404" {
  command = plan

  assert {
    condition     = cloudflare_zero_trust_tunnel_cloudflared_config.this.config.ingress[length(var.hostnames)].service == "http_status:404"
    error_message = "The last ingress rule must catch everything else"
  }
}

run "no_internal_hostnames" {
  command = plan

  assert {
    condition     = length([for h in var.hostnames : h if endswith(h, ".sol.milkyway")]) == 0
    error_message = "Internal names must never traverse the tunnel"
  }
}

run "hostnames_are_unique" {
  command = plan

  variables {
    hostnames = ["tjzimmerman.com", "tjzimmerman.com"]
  }

  expect_failures = [var.hostnames]
}

run "cert_manager_can_only_edit_dns_on_these_zones" {
  command = plan

  assert {
    condition     = toset([for g in cloudflare_account_token.cert_manager.policies[0].permission_groups : g.id]) == toset(["4755a26eedb94da69e1066d98aa820be", "c8fed203ed3043cba015a93ad1616f1f"])
    error_message = "cert-manager needs zone-scoped DNS Write and Zone Read, and nothing else"
  }

  assert {
    condition     = length(keys(jsondecode(cloudflare_account_token.cert_manager.policies[0].resources))) == length(data.cloudflare_zone.this)
    error_message = "cert-manager's token must cover exactly the tunnel's zones"
  }
}
