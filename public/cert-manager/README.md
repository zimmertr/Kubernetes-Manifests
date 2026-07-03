# Cert Manager

* [Summary](#summary)
* [Instructions](#instructions)

## Summary

[cert-manager](https://cert-manager.io) issues and renews TLS certificates. The `letsencrypt` ClusterIssuer solves ACME challenges with the **DNS-01** method via Cloudflare, so it works behind the Cloudflare proxy and supports wildcards. Gateway certificates are issued into the `istio-gateway` namespace (see [istio/istio-gateway](../../istio/istio-gateway)), where the shared Istio ingress gateway can load them.

<hr>

## Instructions

The DNS-01 solver needs a Cloudflare API token, provided as a Kubernetes secret. It is applied out-of-band — only a redacted example is committed ([configs/api-token.example](configs/api-token.example)); the real value in `configs/api-token` is gitignored.

> **The secret key must be `api-token`** (that is what the ClusterIssuer references). The steps below store the token in a file named literally `api-token` so that `kubectl --from-file` derives that exact key from the filename. Do **not** rename the file or add a `key=` override — if the key doesn't match, issuance fails with `specified key "api-token" not found in secret cert-manager/cloudflare-api-token`.

1. Create a Cloudflare API token: **Manage Account → API Tokens → Create Token** (an account-owned token, not a personal one).

   * Permissions: **Zone → DNS → Edit** and **Zone → Zone → Read**
   * Zone Resources: **Include** the zones you need certificates for (or **All zones from an account**)

2. Save the token into the gitignored file `configs/api-token` (use `printf` to avoid a trailing newline, which breaks token auth):

   ```bash
   printf '%s' '<PASTE_TOKEN>' > configs/api-token
   ```

3. Create the secret from that file. The key is taken from the filename, so it becomes `api-token`, matching the ClusterIssuer:

   ```bash
   kubectl create secret generic cloudflare-api-token \
     -n cert-manager \
     --from-file=configs/api-token
   ```

4. Verify the key is present (prints `OK`, not the error):

   ```bash
   kubectl get secret cloudflare-api-token -n cert-manager \
     -o jsonpath='{.data.api-token}' | grep -q . \
     && echo OK || echo "ERROR: key 'api-token' missing"
   ```
