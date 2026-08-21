# Misc

* [Summary](#summary)
* [Instructions](#instructions)
  * [Kubelet CSR Approver](#kubelet-csr-approver)
  * [Cloudflared](#cloudflared)

<hr>

## Summary

Misc is a miscellaneous applications.

<hr>

## Instructions

### Heimdall

```bash
kustomize build --enable-helm heimdall | kubectl apply -f-
```

### Homepage

Update `homepage/files/{configs,icons,images}` according to your needs then install with `kubectl` or Argo CD. `seed-volumes.sh` will automatically seed volumes with your configuration files, images, and icons on init.

```bash
kustomize build --enable-helm homepage | kubectl apply -f-
```

### Kubelet CSR Approver

Cilium and Metrics Server will not be completely ready until you approve the necessary Certificate Signing Requests. This can be done manually with `kubectl certificate approve`, or you can use [Kubelet CSR Approver](https://github.com/postfinance/kubelet-csr-approver).

```bash
kustomize build --enable-helm kubelet-csr-approver | kubectl apply -f-
```

### Mountaineers Activity Scraper

A CronJob to run this project once a day: https://github.com/zimmertr/Mountaineers-Activity-Scraper

The tool will not run successfully until a Google Cloud Credentials secret has been created. This can be done manually with:

```bash
kubectl create ns mountaineers-activity-scraper

kubectl create secret generic mountaineers-activity-scraper-creds \
  --from-file=mountaineers-activity-scraper/files/google_cloud_credentials.json \
  -n mountaineers-activity-scraper-system
```

### Cloudflared

A [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/) that terminates public traffic for every zone this cluster serves and forwards it to the shared Istio ingress gateway. It replaces the inbound `443` port forward, so the origin has no open inbound port and is never reachable off the Cloudflare path (bluebird issue [#148](https://github.com/zimmertr/bluebird/issues/148)).

One shared tunnel serves all public hostnames. The ingress rules live in `cloudflared/files/config.yaml`; only `credentials.json` is a secret, created manually. Internal `*.sol.milkyway` names are deliberately absent from the config, so they never traverse the tunnel.

The Deployment stays unhealthy until the credentials secret exists. Set it up as follows.

1. Install `cloudflared` locally and log in. This opens a browser to pick the account and grants a local certificate for tunnel management.

   ```bash
   cloudflared tunnel login
   ```

2. Create the tunnel. The name must match `tunnel:` in `cloudflared/files/config.yaml` (`tks-ingress`). This writes a `<UUID>.json` credentials file under `~/.cloudflared/`.

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

5. Point each public hostname at the tunnel. This creates a proxied `CNAME` to `<UUID>.cfargotunnel.com` in Cloudflare for every zone (`bluebirdforecast.com`, `tjzimmerman.com`, `tjzimmerman.dev`, each with `www`). Run it for all six, or add the records in the dashboard.

   ```bash
   for host in \
     bluebirdforecast.com www.bluebirdforecast.com \
     tjzimmerman.com www.tjzimmerman.com \
     tjzimmerman.dev www.tjzimmerman.dev; do
       cloudflared tunnel route dns tks-ingress "$host"
   done
   ```

6. Verify each hostname serves through the tunnel, then remove the inbound `443` port forward on OPNsense. Only after the forward is gone is the direct-to-origin path closed.

