# Cloudflare

Terraform for the Cloudflare side of the [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/): the tunnel, its ingress rules, a proxied `CNAME` for each hostname in [cloudflare.tfvars](cloudflare.tfvars), and the token cert-manager uses for DNS-01 challenges. Every public hostname goes through the tunnel to the shared Istio ingress gateway, so the origin has no open inbound port. Internal `*.sol.milkyway` names are never in that list, so they never traverse the tunnel.

1. Create a Cloudflare API token with **Account → Cloudflare Tunnel → Edit**, **Account → Account API Tokens → Edit**, **Zone → Zone → Read** and **Zone → DNS → Edit** on the zones you serve, and export it. The API Tokens permission lets it create cert-manager's token:

   ```bash
   export CLOUDFLARE_API_TOKEN="REPLACEME"
   ```

2. I keep the state in [HCP Terraform](https://app.terraform.io), in the `cloudflare` workspace of the `Kubernetes-Manifests` organization, so run `terraform login` before `terraform init`. Its *Default Execution Mode* is set to *Local*, otherwise HCP tries to run the plan itself.

To add a public hostname, add it to `cloudflare.tfvars` and apply again. The tunnel token doesn't change, so cloudflared picks the new rule up on its own.
