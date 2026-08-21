# Public

* [Summary](#summary)
* [Instructions](#instructions)
  * [Bluebird](#bluebird)
  * [Bluebird PR](#bluebird-pr)
  * [CertManager](#certmanager)
  * [Cloudflared](#cloudflared)
  * [Personal Website](#personal-website)

<hr>

## Summary

Public is a collection of my public-facing applications.

<hr>

## Instructions

### Bluebird

[Bluebird](https://bluebirdforecast.com) is a map-based weather window finder for hikers and mountaineers. The Kustomize project inflates the [bluebird-helm](https://artifacthub.io/packages/helm/bluebird-helm/bluebird-helm) OCI chart and deploys behind Argo Rollouts (canary) and an Istio VirtualService.

The image tag in [bluebird/kustomization.yml](bluebird/kustomization.yml) is bumped automatically by the release workflow in [zimmertr/bluebird](https://github.com/zimmertr/bluebird) on every merge to `main`. Edit it by hand only to pin or roll back.

1. Modify the Kustomize project as per your needs.

2. Deploy to Kubernetes:
   ```bash
   kustomize build --enable-helm bluebird | kubectl apply -f-
   ```

### Bluebird PR

Bluebird PR provides ephemeral preview environments, one per pull request in [zimmertr/bluebird](https://github.com/zimmertr/bluebird). An Argo CD `pullRequest` generator watches for PRs labeled `create pr container` and deploys the `zimmertr/bluebird-pr:pr-<number>-<sha>` image at `pr-<number>.ganymede.sol.milkyway`. Applications are pruned automatically once the PR is closed or the label is removed.

Unlike the rest of `public/`, this directory has no Kustomize project. It owns its own `ApplicationSet` and `AppProject`, and is excluded from the `public/*` generator in [applicationset.yml](applicationset.yml) so the [root generators](../README.md#argo-cd) manage it directly. Nothing needs to be applied by hand once the cluster is bootstrapped.

1. To apply the resources ahead of a bootstrap, or after editing them:
   ```bash
   kubectl apply -f bluebird-pr/appproject.yml
   kubectl apply -f bluebird-pr/applicationset.yml
   ```

### CertManager

[Cert Manager](https://cert-manager.io/) is a tool used to request and manage X509 certificates.

1. Modify the Kustomize project as per your needs.

2. Deploy to Kubernetes:
   ```bash
   kustomize build --enable-helm cert-manager | kubectl apply -f-
   ```

### Cloudflared

A [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/) that terminates all public traffic and forwards it to the shared Istio ingress gateway. It replaces the inbound `443` port forward, so the origin holds no open inbound port and is never reachable off the Cloudflare path (bluebird issue [#148](https://github.com/zimmertr/bluebird/issues/148)).

One shared tunnel serves every public hostname. The ingress rules live in [cloudflared/files/config.yaml](cloudflared/files/config.yaml); only `credentials.json` is a secret, created by hand, the same split the [Proxmox CSI Plugin](../storage/README.md#proxmox-csi-plugin) uses. Internal `*.sol.milkyway` names are absent from the config, so they never traverse the tunnel. The pod opts out of the mesh (`sidecar.istio.io/inject: "false"`) because it originates its own TLS to the gateway.

The Deployment stays unhealthy until the credentials secret exists. Set it up as follows.

1. Install `cloudflared` locally and log in. This opens a browser to pick the account and grants a local certificate for tunnel management.

   ```bash
   cloudflared tunnel login
   ```

2. Create the tunnel. The name must match `tunnel:` in [cloudflared/files/config.yaml](cloudflared/files/config.yaml) (`tks-ingress`). This writes a `<UUID>.json` credentials file under `~/.cloudflared/`.

   ```bash
   cloudflared tunnel create tks-ingress
   ```

3. Create the credentials secret from that file.

   ```bash
   kubectl create ns cloudflared-system

   kubectl create secret generic cloudflared-credentials \
     --from-file=credentials.json=$HOME/.cloudflared/<UUID>.json \
     -n cloudflared-system
   ```

4. Deploy (or let Argo CD sync it).

   ```bash
   kustomize build cloudflared | kubectl apply -f-
   ```

5. Point each public hostname at the tunnel. This creates a proxied `CNAME` to `<UUID>.cfargotunnel.com` for every zone (`bluebirdforecast.com`, `tjzimmerman.com`, `tjzimmerman.dev`, each with `www`). Run it for all six, or add the records in the dashboard.

   ```bash
   for host in \
     bluebirdforecast.com www.bluebirdforecast.com \
     tjzimmerman.com www.tjzimmerman.com \
     tjzimmerman.dev www.tjzimmerman.dev; do
       cloudflared tunnel route dns tks-ingress "$host"
   done
   ```

6. Verify each hostname serves through the tunnel, then remove the inbound `443` port forward on OPNsense. Only after the forward is gone is the direct-to-origin path closed.

### Personal Website

[Personal Website](https://tjzimmerman.com) is my personal website.

1. Modify the Kustomize project as per your needs.

2. Deploy to Kubernetes:
   ```bash
   kustomize build --enable-helm personal-website | kubectl apply -f-
   ```
