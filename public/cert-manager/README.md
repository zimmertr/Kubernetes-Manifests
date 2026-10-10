# Cert Manager

* [Summary](#summary)
* [Instructions](#instructions)

## Summary

[cert-manager](https://cert-manager.io) issues and renews TLS certificates. The `letsencrypt` ClusterIssuer solves ACME challenges with the **DNS-01** method via Cloudflare, so it works behind the Cloudflare proxy and supports wildcards. Gateway certificates live here too, one per app (e.g. [personal-website](resources/certificate-personal-website.yml)), and are issued into the `istio-gateway` namespace where the shared Istio ingress gateway can load them.

<hr>

## Instructions

The DNS-01 solver needs a Cloudflare API token, provided as the secret `cert-manager/cloudflare-api-token` under the key `api-token`, which is what the ClusterIssuer reads. The token is created by Terraform in [terraform/cloudflare](../../terraform/cloudflare), with DNS edit on the zones the tunnel serves and nothing else. See [Cloudflared](../README.md#cloudflared) for applying it, and [Secrets and Volumes](../../README.md#secrets-and-volumes) in the main README for creating the secret.
