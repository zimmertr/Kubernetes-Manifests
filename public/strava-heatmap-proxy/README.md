# Strava Heatmap Proxy

A reverse proxy in front of the [Strava global heatmap](https://www.strava.com/maps/global-heatmap) and my personal heatmap, so they can be added to CalTopo (or any app that takes an XYZ tile URL) as a custom layer. Strava serves the high-zoom tiles only with signed CloudFront cookies, which CalTopo cannot send. The proxy is [patrickziegler/strava-heatmap-proxy](https://github.com/patrickziegler/strava-heatmap-proxy): it holds one `_strava4_session` cookie from a logged-in browser, exchanges it for CloudFront cookies, refreshes them as they expire, and forwards tile requests with the cookies attached. The URL never expires. Only the session cookie does, after a month or a few, and then the pod crash loops until a fresh one is exported.

Two processes run in one pod because the upstream proxy takes a single target: one for the global heatmap (`/global/`) and one for the personal heatmap (`/personal/`, athlete id set as `STRAVA_ATHLETE_ID` in [kustomization.yml](kustomization.yml)). The VirtualService strips the prefix. The cookie file is a secret created by hand. The certificate lives with the other public ones in [cert-manager](../cert-manager), and the hostname is routed through the tunnel by [cloudflare.tfvars](../../terraform/cloudflare/cloudflare.tfvars).

1. Export the cookies. Log in to [strava.com](https://www.strava.com) in a browser and either install the [Strava Cookie Exporter](https://github.com/patrickziegler/strava-heatmap-proxy/tree/main/strava-cookie-exporter) extension and click Export, or copy the `_strava4_session` value from the browser's cookie storage into the shape of [files/strava-cookies.json.example](files/strava-cookies.json.example). Save it as `files/strava-cookies.json` (gitignored).

2. Create the secret with the Strava command in [Secrets and Volumes](../../README.md#secrets-and-volumes) in the main README. Whenever the pod crash loops, export a fresh cookie, run that command again and restart the pod:

   ```bash
   kubectl rollout restart deployment strava-heatmap-proxy -n strava-heatmap-proxy-system
   ```

3. Add the layers in CalTopo under Add, Custom Source: type Tile, Max Zoom 15 (neither heatmap has tiles past 15), overlay Yes - Transparent Overlay, then Save To Account. Tiles are 512px with no query string; add `?px=256` to the global URLs for the old size.

   ```text
   https://stravaproxy.tjzimmerman.com/global/run/hot/{Z}/{X}/{Y}.png
   https://stravaproxy.tjzimmerman.com/global/winter/blue/{Z}/{X}/{Y}.png
   https://stravaproxy.tjzimmerman.com/global/all/hot/{Z}/{X}/{Y}.png
   https://stravaproxy.tjzimmerman.com/global/ride/purple/{Z}/{X}/{Y}.png
   https://stravaproxy.tjzimmerman.com/personal/purple/{Z}/{X}/{Y}.png?filter_type=all&include_everyone=true&include_followers_only=true&include_only_me=true&respect_privacy_zones=false&include_commutes=true
   ```

   The tables below list every activity and color name that was verified against the proxy.

4. Tile reference. Every global URL follows this pattern:

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
