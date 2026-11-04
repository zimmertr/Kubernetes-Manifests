# hevy2garmin

[hevy2garmin](https://github.com/drkostas/hevy2garmin) merges the workouts I log in Hevy into the Strength Training activity my watch recorded, so Garmin Connect has the exercises, sets, reps and weights next to the watch's heart rate and Training Effect. Garmin forwards that activity to Strava. It also turns each Hevy routine into a Garmin planned workout, so the watch walks me through the exercises instead of guessing them.

The dashboard is LAN only at [192.168.40.102](http://192.168.40.102). Its Postgres is a [CloudNativePG](../cloudnative-pg) cluster; the Hevy key and Garmin login are entered in the dashboard and live there, not in git.

## Image

Upstream publishes no container image, and its Dockerfile is meant to be built on the machine that runs it. Build `web/` from a checkout of the commit you want and tag the image with that commit:

```bash
git clone https://github.com/drkostas/hevy2garmin.git
cd hevy2garmin/web
docker buildx build --platform linux/amd64 --push -t "zimmertr/hevy2garmin-web:$(git rev-parse HEAD)" .
```

Then set that commit as `newTag` in [kustomization.yml](kustomization.yml). Renovate doesn't follow commit tags, so updating is the same two steps again.

## Setup

1. Create the secret from the root README's [Secrets and Volumes](../../README.md#secrets-and-volumes).

2. Open the dashboard, log in with the password from the secret, and on the setup page enter the Hevy API key from [hevy.com/settings?developer](https://hevy.com/settings?developer) (needs Hevy Pro) and the Garmin email and password. The 2FA code is asked for inline. Garmin rate-limits logins for hours if you retry, so get it right once.

3. In Settings, set the timezone, turn on *Enhance Watch Activities* and pick the *Merge* strategy. Merge keeps the watch's activity and writes the Hevy sets into it. *Replace* uploads a copy and deletes the watch's, which loses Training Effect and leaves a duplicate on Strava.

4. On the Routines page, sync each routine to Garmin. They show up under Training → Workouts on the watch.

5. In Hevy, disconnect Strava (Profile → Settings → Integrations). Garmin Connect stays connected to Strava, otherwise every workout lands there twice.

## At the gym

Start the planned workout on the watch and log the workout in Hevy on the phone as usual, starting and stopping both within a few minutes of each other. The [CronJob](resources/cronjob.yml) runs every 15 minutes, but hevy2garmin holds a workout for two hours after it ends so the watch has time to sync its recording, so the merge lands on the first run after that. *Sync Now* in the dashboard skips the wait; only press it once the watch has synced, or it uploads a second activity instead of merging.
