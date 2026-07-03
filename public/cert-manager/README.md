# Cert Manager

* [Summary](#summary)
* [Instructions](#instructions)

## Summary

[cert-manager](https://cert-manager.io) issues and renews TLS certificates. The `letsencrypt` ClusterIssuer solves ACME challenges with the **DNS-01** method via Cloudflare, so it works behind the Cloudflare proxy and supports wildcards. Gateway certificates are issued into the `istio-gateway` namespace (see [istio/istio-gateway](../../istio/istio-gateway)), where the shared Istio ingress gateway can load them.

<hr>

## Instructions

The DNS-01 solver needs a Cloudflare API token, provided as a Kubernetes secret. It is applied out-of-band — only a redacted example is committed ([configs/cloudflare-api-token.example](configs/cloudflare-api-token.example)); the real value in `configs/cloudflare-api-token` is gitignored.

1. Create a Cloudflare API token: **My Profile → API Tokens → Create Token**.

   * Permissions: **Zone → DNS → Edit**
   * Zone Resources: **Include** `bluebirdforecast.com`, `tjzimmerman.com`, `tjzimmerman.dev`

2. Save the token into the gitignored file using [configs/cloudflare-api-token.example](configs/cloudflare-api-token.example) as an example (use `printf` to avoid a trailing newline):

   ```bash
   printf '%s' '<PASTE_TOKEN>' > configs/cloudflare-api-token
   ```

3. Create the secret. The key must be `api-token` to match the ClusterIssuer.

   ```bash
   kubectl create secret generic cloudflare-api-token \
     -n cert-manager \
     --from-file=api-token=configs/cloudflare-api-token
   ```