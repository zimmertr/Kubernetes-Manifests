# Public

* [Summary](#summary)
* [Instructions](#instructions)
  * [Bluebird](#bluebird)
  * [Bluebird PR](#bluebird-pr)
  * [CertManager](#certmanager)
  * [Cloudflared](#cloudflared)
  * [Personal Website](#personal-website)
  * [Strava Heatmap Proxy](#strava-heatmap-proxy)

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

### Strava Heatmap Proxy

A reverse proxy in front of the [Strava global heatmap](https://www.strava.com/maps/global-heatmap) and my personal heatmap, so they can be added to CalTopo (or any app that takes an XYZ tile URL) as a custom layer. Strava serves the high-zoom tiles only with signed CloudFront cookies, which CalTopo cannot send. The proxy is [patrickziegler/strava-heatmap-proxy](https://github.com/patrickziegler/strava-heatmap-proxy): it holds one `_strava4_session` cookie from a logged-in browser, exchanges it for CloudFront cookies, refreshes them as they expire, and forwards tile requests with the cookies attached. The URL never expires. Only the session cookie does, after a month or a few, and then the pod crash loops until a fresh one is exported.

Two processes run in one pod because the upstream proxy takes a single target: one for the global heatmap (`/global/`) and one for the personal heatmap (`/personal/`, athlete id set as `STRAVA_ATHLETE_ID` in [strava-heatmap-proxy/kustomization.yml](strava-heatmap-proxy/kustomization.yml)). The VirtualService strips the prefix. The cookie file is a secret created by hand, the same split as [Cloudflared](#cloudflared).

1. Export the cookies. Log in to [strava.com](https://www.strava.com) in a browser and either install the [Strava Cookie Exporter](https://github.com/patrickziegler/strava-heatmap-proxy/tree/main/strava-cookie-exporter) extension and click Export, or copy the `_strava4_session` value from the browser's cookie storage into the shape of [strava-heatmap-proxy/files/strava-cookies.json.example](strava-heatmap-proxy/files/strava-cookies.json.example). Save it as `strava-heatmap-proxy/files/strava-cookies.json` (gitignored).

2. Create the secret. Repeat this step with a fresh export whenever the pod crash loops.

   ```bash
   kubectl create ns strava-heatmap-proxy-system

   kubectl create secret generic strava-heatmap-proxy-cookies \
     --from-file=strava-cookies.json=strava-heatmap-proxy/files/strava-cookies.json \
     -n strava-heatmap-proxy-system --dry-run=client -o yaml | kubectl apply -f-

   kubectl rollout restart deployment strava-heatmap-proxy -n strava-heatmap-proxy-system
   ```

3. Deploy (or let Argo CD sync it). The certificate lives with the other public ones in [istio/istio-gateway](../istio/istio-gateway), and the hostname is routed through the tunnel by [cloudflared/files/config.yaml](cloudflared/files/config.yaml).

   ```bash
   kustomize build strava-heatmap-proxy | kubectl apply -f-
   ```

4. Add the layers in CalTopo under Add, Custom Source: type Tile, Max Zoom 15 (neither heatmap has tiles past 15), overlay Yes - Transparent Overlay, then Save To Account. Tiles are 512px with no query string; add `?px=256` to the global URLs for the old size.

   ```text
   https://stravaproxy.tjzimmerman.com/global/run/hot/{Z}/{X}/{Y}.png
   https://stravaproxy.tjzimmerman.com/global/winter/blue/{Z}/{X}/{Y}.png
   https://stravaproxy.tjzimmerman.com/global/all/hot/{Z}/{X}/{Y}.png
   https://stravaproxy.tjzimmerman.com/global/ride/purple/{Z}/{X}/{Y}.png
   https://stravaproxy.tjzimmerman.com/personal/purple/{Z}/{X}/{Y}.png?filter_type=all&include_everyone=true&include_followers_only=true&include_only_me=true&respect_privacy_zones=false&include_commutes=true
   ```

   The tables below list every activity and color name that was verified against the proxy.

5. Tile reference. Every global URL follows this pattern:

   ```text
   https://stravaproxy.tjzimmerman.com/global/<activity>/<color>/{Z}/{X}/{Y}.png
   ```

   Validity was tested on two tiles, Seattle at zoom 10 and Rampart Lakes at zoom 12. A 404 means no data in that tile, a 400 means Strava rejects the name. Names cannot be combined; every separator tried returned 400.

   | Group | Contains | Example |
   |---|---|---|
   | `all` | everything below | `/global/all/hot/{Z}/{X}/{Y}.png` |
   | `run` | Run, TrailRun, Walk, Hike. Confirmed: 100 percent of each sport's pixels appear in this group | `/global/run/hot/{Z}/{X}/{Y}.png` |
   | `ride` | Ride, MountainBikeRide, GravelRide, EBikeRide, EMountainBikeRide | `/global/ride/purple/{Z}/{X}/{Y}.png` |
   | `winter` | Snowshoe, BackcountrySki, NordicSki confirmed at 100 percent. AlpineSki, Snowboard, IceSkate assumed | `/global/winter/blue/{Z}/{X}/{Y}.png` |
   | `water` | paddling, rowing, sailing, swimming, surf sports | `/global/water/blue/{Z}/{X}/{Y}.png` |

   | Single sport, valid with data seen | Example |
   |---|---|
   | `sport_Hike`, `sport_TrailRun`, `sport_Run`, `sport_Walk` | `/global/sport_Hike/hot/{Z}/{X}/{Y}.png` |
   | `sport_Snowshoe`, `sport_BackcountrySki`, `sport_NordicSki`, `sport_IceSkate`, `sport_RollerSki` | `/global/sport_BackcountrySki/blue/{Z}/{X}/{Y}.png` |
   | `sport_Ride`, `sport_MountainBikeRide`, `sport_GravelRide`, `sport_EBikeRide`, `sport_EMountainBikeRide` | `/global/sport_MountainBikeRide/purple/{Z}/{X}/{Y}.png` |
   | `sport_Kayaking`, `sport_Canoeing`, `sport_StandUpPaddling`, `sport_Rowing`, `sport_Swim`, `sport_Sail`, `sport_Windsurf`, `sport_Kitesurf` | `/global/sport_Kayaking/blue/{Z}/{X}/{Y}.png` |
   | `sport_RockClimbing`, `sport_InlineSkate`, `sport_Skateboard`, `sport_Golf`, `sport_Soccer`, `sport_Tennis`, `sport_Pickleball`, `sport_Badminton`, `sport_Wheelchair`, `sport_Workout`, `sport_VirtualRun`, `sport_VirtualRide` | `/global/sport_RockClimbing/orange/{Z}/{X}/{Y}.png` |

   | Single sport, accepted but no data in either test tile | Example |
   |---|---|
   | `sport_AlpineSki`, `sport_Snowboard`, `sport_Surfing`, `sport_Velomobile`, `sport_Handcycle` | `/global/sport_AlpineSki/blue/{Z}/{X}/{Y}.png` |
   | `sport_Elliptical`, `sport_Crossfit`, `sport_Yoga`, `sport_WeightTraining`, `sport_StairStepper`, `sport_Pilates`, `sport_TableTennis`, `sport_Squash`, `sport_Racquetball`, `sport_HighIntensityIntervalTraining` | indoor, expect nothing |

   Rejected with 400: `foot`, `cycling`, `ski`, `hike`, `walk`, `other`, `sport_Ski`, `sport_Snowmobile`, `sport_Motorcycle`, `sport_Horseback`, `sport_Sailing`.

   Colors. Eight distinct palettes; any other word silently gives `hot`. The first seven are palette PNGs with transparency. `grayscale` is an opaque PNG with no alpha (it is what strava.com draws on its dark basemap), so it blacks out the map as an overlay.

   | Color | Example |
   |---|---|
   | `hot` | `/global/all/hot/{Z}/{X}/{Y}.png` |
   | `blue` | `/global/all/blue/{Z}/{X}/{Y}.png` |
   | `purple` | `/global/all/purple/{Z}/{X}/{Y}.png` |
   | `gray` | `/global/all/gray/{Z}/{X}/{Y}.png` |
   | `orange` | `/global/all/orange/{Z}/{X}/{Y}.png` |
   | `bluered` | `/global/all/bluered/{Z}/{X}/{Y}.png` |
   | `mobileblue` | `/global/all/mobileblue/{Z}/{X}/{Y}.png` |
   | `grayscale` | `/global/all/grayscale/{Z}/{X}/{Y}.png` (opaque) |

   The personal URL is the request the Strava site itself makes. `filter_type` and at least one `include_*` visibility flag are required or the tile comes back blank; the three `include_*` flags select activities by their visibility setting, `respect_privacy_zones` hides track segments inside privacy zones, and `include_commutes` adds commutes. The Strava site also sends `missing=empty`, which turns empty tiles into an opaque black placeholder PNG instead of a 404; leave it out, CalTopo draws a 404 as transparent. `filter_type` takes a `sport_` name too, and `@2x.png` doubles the tile size. Cloudflare caches global tiles for 7 days and personal tiles for 4 hours, both set by Strava, so a new activity shows up within 4 hours.

Never share a public CalTopo map with one of these layers enabled unless you are happy for viewers to pull tiles through your Strava account.
