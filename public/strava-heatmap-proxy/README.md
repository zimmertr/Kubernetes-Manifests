# Strava Heatmap Proxy

Serves the Strava global and personal heatmaps as CalTopo tile layers. Strava only serves high-zoom tiles with signed CloudFront cookies, so [strava-heatmap-proxy](https://github.com/patrickziegler/strava-heatmap-proxy) trades a browser session cookie for them. The session cookie expires every month or so, and the pod crash loops until it's replaced.

## Cookies

Log in to [strava.com](https://www.strava.com), export the cookies with the [Strava Cookie Exporter](https://github.com/patrickziegler/strava-heatmap-proxy/tree/main/strava-cookie-exporter) (or copy `_strava4_session` into the shape of `files/strava-cookies.json.example`), and save them as `files/strava-cookies.json`. Then run the Strava command in the root README's [Secrets and Volumes](../../README.md#secrets-and-volumes), and restart the pod:

```bash
kubectl rollout restart deployment strava-heatmap-proxy -n strava-heatmap-proxy-system
```

## CalTopo

Add a Custom Source of type Tile, Max Zoom 15, as a Transparent Overlay:

```text
https://stravaproxy.tjzimmerman.com/global/<activity>/<color>/{Z}/{X}/{Y}.png
https://stravaproxy.tjzimmerman.com/personal/purple/{Z}/{X}/{Y}.png?filter_type=all&include_everyone=true&include_followers_only=true&include_only_me=true&respect_privacy_zones=false&include_commutes=true
```

Activities are `all`, `run`, `ride`, `winter`, `water`, or a single sport like `sport_Hike`. Colors are `hot`, `blue`, `purple`, `gray`, `orange`, `bluered` and `mobileblue`.

Don't share a public CalTopo map with these layers on. Viewers pull tiles through your Strava account.
