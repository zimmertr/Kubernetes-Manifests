# Strava Heatmap Proxy

Serves the [Strava global heatmap](https://www.strava.com/maps/global-heatmap) and my personal heatmap as tile layers for CalTopo, or any app that takes an XYZ tile URL. Strava only serves high-zoom tiles with signed CloudFront cookies, which CalTopo can't send. [strava-heatmap-proxy](https://github.com/patrickziegler/strava-heatmap-proxy) holds a `_strava4_session` cookie from a logged-in browser, trades it for CloudFront cookies, and attaches them to each tile request. The session cookie expires after a month or so, and the pod crash loops until it's replaced.

The pod runs two proxies, one for `/global/` and one for `/personal/`, because the upstream proxy takes a single target. The athlete ID is `STRAVA_ATHLETE_ID` in [kustomization.yml](kustomization.yml).

## Cookies

1. Log in to [strava.com](https://www.strava.com) and export the cookies with the [Strava Cookie Exporter](https://github.com/patrickziegler/strava-heatmap-proxy/tree/main/strava-cookie-exporter) extension, or copy `_strava4_session` into the shape of [the example](files/strava-cookies.json.example).

2. Save them as `files/strava-cookies.json`. It's gitignored.

3. Create the secret from the root README's [Secrets and Volumes](../../README.md#secrets-and-volumes). When you're replacing an expired cookie, restart the pod afterwards:

   ```bash
   kubectl rollout restart deployment strava-heatmap-proxy -n strava-heatmap-proxy-system
   ```

## CalTopo

Add each layer under *Add → Custom Source*: type Tile, Max Zoom 15 (neither heatmap goes past 15), overlay *Yes - Transparent Overlay*, then *Save To Account*. Tiles are 512px; add `?px=256` to the global URLs for the old size.

```text
https://stravaproxy.tjzimmerman.com/global/<activity>/<color>/{Z}/{X}/{Y}.png
https://stravaproxy.tjzimmerman.com/personal/purple/{Z}/{X}/{Y}.png?filter_type=all&include_everyone=true&include_followers_only=true&include_only_me=true&respect_privacy_zones=false&include_commutes=true
```

* Activities: `all`, `run` (runs, trail runs, walks and hikes), `ride`, `winter`, `water`, or a single sport such as `sport_Hike` or `sport_BackcountrySki`. An unknown name returns 400.
* Colors: `hot`, `blue`, `purple`, `gray`, `orange`, `bluered` and `mobileblue`. Any other word gives `hot`. `grayscale` is opaque, so it blacks out the map.
* Cloudflare caches global tiles for 7 days and personal tiles for 4 hours, so a new activity shows up within 4 hours.

Never share a public CalTopo map with these layers on. Viewers pull tiles through your Strava account.
