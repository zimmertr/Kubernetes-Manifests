# Cert Manager

* [Summary](#summary)
* [Instructions](#instructions)

## Summary

[cert-manager](https://cert-manager.io) issues and renews TLS certificates. The `letsencrypt` ClusterIssuer solves ACME challenges with the **DNS-01** method via Cloudflare, so it works behind the Cloudflare proxy and supports wildcards. Gateway certificates live here too, one per app (e.g. [personal-website](resources/certificate-personal-website.yml)), and are issued into the `istio-gateway` namespace where the shared Istio ingress gateway can load them.

<hr>

## Instructions

The DNS-01 solver needs a Cloudflare API token, provided as a Kubernetes secret. The token is created by Terraform in [terraform/cloudflare](../../terraform/cloudflare), with DNS edit on the zones the tunnel serves and nothing else. See the [Cloudflared](../README.md#cloudflared) instructions for applying it.

1. Create the secret from the Terraform output. The ClusterIssuer reads the key `api-token`, so keep that name:

   ```bash
   kubectl create secret generic cloudflare-api-token \
     -n cert-manager \
     --from-literal=api-token="$(terraform -chdir=../../terraform/cloudflare output -raw cert_manager_token)"
   ```

2. Verify the key is present (prints `OK`, not the error):

   ```bash
   kubectl get secret cloudflare-api-token -n cert-manager \
     -o jsonpath='{.data.api-token}' | grep -q . \
     && echo OK || echo "ERROR: key 'api-token' missing"
   ```
