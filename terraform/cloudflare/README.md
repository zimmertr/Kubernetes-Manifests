# Cloudflare

Manages the tunnel, its DNS records and cert-manager's token. State is in HCP Terraform (`Kubernetes-Manifests/cloudflare`, Local execution), so run `terraform login` first.

Export a Cloudflare API token with **Account: Cloudflare Tunnel Edit, Account API Tokens Edit** and **Zone: Zone Read, DNS Edit**:

```bash
export CLOUDFLARE_API_TOKEN="REPLACEME"
```

To add a public hostname, add it to `cloudflare.tfvars` and apply.
