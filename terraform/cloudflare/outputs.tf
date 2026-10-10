output "tunnel_token" {
  value       = data.cloudflare_zero_trust_tunnel_cloudflared_token.this.token
  sensitive   = true
  description = "Token cloudflared runs the tunnel with, for the cloudflared-token secret"
}

output "cert_manager_token" {
  value       = cloudflare_account_token.cert_manager.value
  sensitive   = true
  description = "Token cert-manager solves DNS-01 challenges with, for the cloudflare-api-token secret"
}
