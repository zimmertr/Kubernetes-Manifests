# hevy2garmin

[hevy2garmin](https://github.com/drkostas/hevy2garmin) merges the workouts I log in Hevy into the Strength Training activity my watch recorded, so Garmin Connect has the exercises, sets, reps and weights next to the watch's heart rate and Training Effect. Garmin forwards that activity to Strava. It also turns each Hevy routine into a Garmin planned workout, so the watch walks me through the exercises instead of guessing them.

I use Hevy Trainer, which never creates routines, so a second CronJob runs [hevy-trainer-sync](https://github.com/zimmertr/hevy-trainer-sync) alongside it. That one mirrors the Trainer program into an `Upper` and a `Lower` routine every hour, named for the cycle and week (`Upper C2-W2`), and has hevy2garmin push them to Garmin. Garmin only puts a library workout on the watch after Send to Device, so until that's automated it's a tap on the phone after a routine changes. Strava only ever sees what the watch recorded, so the planned workout is what makes Strava accurate.

The dashboard is LAN only at [192.168.40.102](http://192.168.40.102). Its Postgres is a [CloudNativePG](../cloudnative-pg) cluster. The Hevy API key and the Trainer bootstrap session come from the secret; the Garmin login is entered once in the dashboard and its tokens live in Postgres, not in git.

## Images

Upstream publishes no container image, and its Dockerfile is meant to be built on the machine that runs it. Build `web/` from a checkout of the commit you want and tag the image with that commit:

```bash
git clone https://github.com/drkostas/hevy2garmin.git
cd hevy2garmin/web
docker buildx build --platform linux/amd64 --push -t "zimmertr/hevy2garmin-web:$(git rev-parse HEAD)" .
```

hevy-trainer-sync is built the same way from its own repo:

```bash
git clone https://github.com/zimmertr/hevy-trainer-sync.git
cd hevy-trainer-sync
docker buildx build --platform linux/amd64 --push -t "zimmertr/hevy-trainer-sync:$(git rev-parse HEAD)" .
```

Then set the commit as `newTag` in [kustomization.yml](kustomization.yml). Renovate doesn't follow commit tags, so updating is the same two steps again.

## Setup

1. Create the secret from the root README's [Secrets and Volumes](../../README.md#secrets-and-volumes). The session is the `auth2.0-token` cookie on hevy.com (DevTools → Application → Cookies), pasted whole; both tokens in it are needed. hevy-trainer-sync uses it once, on its first run, then keeps the rotating replacement on its own volume. If that volume is ever lost, paste a fresh cookie into the secret.

2. Open the dashboard, log in with the password from the secret, and on the setup page enter the Garmin email and password. The 2FA code is asked for inline. Garmin rate-limits logins for hours if you retry, so get it right once. Hevy already shows as connected, from the key in the secret.

3. In Settings, set the timezone, set the sync start date to the day the watch started recording alongside Hevy, turn on *Enhance Watch Activities* and pick the *Merge* strategy, then press Save. Merge keeps the watch's activity and writes the Hevy sets into it. *Replace* uploads a copy and deletes the watch's, which loses Training Effect and leaves a duplicate on Strava. A start date earlier than the watch recordings uploads every older Hevy workout as a new activity, and Garmin forwards each one to Strava.

4. Wait for the next hourly run of hevy-trainer-sync, or trigger one. The Routines page then shows the `Hevy Trainer` folder with the routines already synced; they show up under Training → Workouts on the watch.

5. In Hevy, disconnect Strava (Profile → Settings → Integrations). Garmin Connect stays connected to Strava, otherwise every workout lands there twice.

## At the gym

Start the planned workout on the watch (Training → Workouts → the current `Upper` or `Lower`) and log the workout in Hevy on the phone as usual, starting and stopping both within a few minutes of each other. The [CronJob](resources/cronjob.yml) runs every 15 minutes, but hevy2garmin holds a workout for two hours after it ends so the watch has time to sync its recording, so the merge lands on the first run after that. *Sync Now* in the dashboard skips the wait; only press it once the watch has synced, or it uploads a second activity instead of merging.

Trainer's next workout only changes when a session finishes or the weekly rotation runs, so the hourly [trainer sync](resources/trainer-sync.yml) has the watch current well before the next session. An exercise swapped in the Hevy app mid-workout isn't on the watch for that session; the merge still fixes Garmin Connect afterwards.
