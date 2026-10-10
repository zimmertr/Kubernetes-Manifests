# The Cloudflare side of the public ingress: one remotely-managed tunnel, its
# ingress rules, a proxied CNAME per public hostname, and the token cert-manager
# solves DNS-01 challenges with. cloudflared in public/cloudflared runs with
# this tunnel's token and reads the rules from Cloudflare, so the hostname list
# in cloudflare.tfvars is the only place a public hostname is declared.
terraform {
  required_version = ">= 1.16"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.27.0"
    }
  }

  cloud {
    organization = "Kubernetes-Manifests"
    workspaces {
      name = "cloudflare"
    }
  }
}

# Reads CLOUDFLARE_API_TOKEN from the environment.
provider "cloudflare" {}

locals {
  # Every zone here is a registered domain plus one TLD label, so the zone is
  # the last two labels of the hostname.
  zones = toset([for h in var.hostnames : regex("[^.]+\\.[^.]+$", h)])
}

data "cloudflare_zone" "this" {
  for_each = local.zones

  filter = {
    name = each.key
  }
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "this" {
  account_id = var.account_id
  name       = var.tunnel_name
  config_src = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "this" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.this.id

  config = {
    ingress = concat(
      [for h in var.hostnames : {
        hostname = h
        service  = var.service
        # The gateway serves each hostname's own Let's Encrypt certificate, so
        # cloudflared verifies it by sending the hostname as SNI instead of
        # skipping verification.
        origin_request = {
          origin_server_name = h
        }
      }],
      # Anything else that reaches the tunnel is not a hostname we serve.
      [{ service = "http_status:404" }],
    )
  }
}

resource "cloudflare_dns_record" "this" {
  for_each = toset(var.hostnames)

  zone_id = data.cloudflare_zone.this[regex("[^.]+\\.[^.]+$", each.key)].id
  name    = each.key
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.this.id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
  comment = "Routed through the ${var.tunnel_name} tunnel"
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "this" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.this.id
}

# cert-manager's DNS-01 solver writes a TXT record to prove each certificate's
# hostname, so it gets DNS edit on the tunnel's zones and nothing else.
resource "cloudflare_account_token" "cert_manager" {
  account_id = var.account_id
  name       = "cert-manager"

  policies = [{
    effect = "allow"
    # Cloudflare's fixed IDs for the zone-scoped "DNS Write" and "Zone Read"
    # permission groups.
    permission_groups = [
      { id = "4755a26eedb94da69e1066d98aa820be" },
      { id = "c8fed203ed3043cba015a93ad1616f1f" },
    ]
    resources = jsonencode({ for z in data.cloudflare_zone.this : "com.cloudflare.api.account.zone.${z.id}" => "*" })
  }]
}
