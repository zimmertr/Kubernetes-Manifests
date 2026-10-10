output "tunnel_token" {
  value       = data.cloudflare_zero_trust_tunnel_cloudflared_token.this.token
  sensitive   = true
  description = "Token cloudflared runs the tunnel with, for the cloudflared-token secret"
}
