# Cloudflare

Terraform for the Cloudflare side of my public ingress. It manages:

* The `tks-ingress` tunnel and its ingress rules, which send every hostname in [cloudflare.tfvars](cloudflare.tfvars) to the Istio gateway
* A proxied `CNAME` for each of those hostnames
* The API token cert-manager uses for DNS-01 challenges

Its outputs become the `cloudflared-token` and `cloudflare-api-token` secrets in the root README's [Secrets and Volumes](../../README.md#secrets-and-volumes).

1. Create a Cloudflare API token with **Account → Cloudflare Tunnel → Edit**, **Account → Account API Tokens → Edit**, **Zone → Zone → Read** and **Zone → DNS → Edit**, and export it. The API Tokens permission is what lets it create cert-manager's token.

   ```bash
   export CLOUDFLARE_API_TOKEN="REPLACEME"
   ```

2. Run `terraform login`. The state is in [HCP Terraform](https://app.terraform.io), in the `cloudflare` workspace of the `Kubernetes-Manifests` organization. Its *Default Execution Mode* is *Local*, otherwise HCP tries to run the plan itself and can't.

3. Apply it with the commands in the root README.

To add a public hostname, add it to `cloudflare.tfvars` and apply again. cloudflared picks up the new rule without a restart.
