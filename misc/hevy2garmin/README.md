# hevy2garmin

[hevy2garmin](https://github.com/drkostas/hevy2garmin) merges the workouts I log in Hevy into the Strength Training activity my watch recorded, so Garmin Connect has the exercises, sets, reps and weights next to the watch's heart rate and Training Effect. Garmin forwards that activity to Strava. It also turns each Hevy routine into a Garmin planned workout, so the watch walks me through the exercises instead of guessing them.

I use Hevy Trainer, which never creates routines, so a second CronJob runs [hevy-trainer-sync](https://github.com/zimmertr/hevy-trainer-sync) alongside it. That one mirrors the Trainer program into one routine per template every hour, named for the program week (`Upper W8`, `Lower W8`), has hevy2garmin push them to Garmin, and puts Trainer's next one on today's date in the Garmin calendar, which is how it gets to the watch. Garmin keeps calendar workouts in step with the watch, so when a routine changes the watch gets the new one instead of a second copy. Garmin forwards what the watch recorded to Strava the moment it syncs, and Strava never picks up anything after that, so the planned workout is what makes Strava right. The merge only fixes Garmin Connect.

The same image also runs as the `hevy-trainer-poll` Deployment. It checks Hevy every minute for a saved workout, waits until Garmin has the watch's activity for it, and only then calls hevy2garmin's webhook route itself, so Garmin Connect has the merge a minute or two after the watch syncs, without exposing anything to the internet. Because it only asks once the activity is there, hevy2garmin always merges and never uploads one of its own, so nothing but the watch reaches Strava.

The dashboard is LAN only at [192.168.40.102](http://192.168.40.102). Its Postgres is a [CloudNativePG](../cloudnative-pg) cluster. The Hevy API key and the Trainer bootstrap session come from the secret; the Garmin login is entered once in the dashboard and its tokens live in Postgres, not in git.

## Images

Upstream publishes no container image, and its Dockerfile is meant to be built on the machine that runs it. Build `web/` from a checkout of the commit you want and tag the image with that commit:

```bash
git clone https://github.com/drkostas/hevy2garmin.git
cd hevy2garmin/web
docker buildx build --platform linux/amd64 --push -t "zimmertr/hevy2garmin-web:$(git rev-parse HEAD)" .
```

Then set the commit as `newTag` in [kustomization.yml](kustomization.yml). Renovate doesn't follow commit tags, so updating is the same two steps again.

hevy-trainer-sync doesn't need any of that. Its CI cuts a release on every merge to main and opens a PR here that bumps its `newTag` to the new version and merges itself. The CronJob and the poller share that one tag.

## Setup

1. Create the secret from the root README's [Secrets and Volumes](../../README.md#secrets-and-volumes). The session is the `auth2.0-token` cookie on hevy.com (DevTools → Application → Cookies), pasted whole; both tokens in it are needed. hevy-trainer-sync uses it once, on its first run, then keeps the rotating replacement on its own volume. If that volume is ever lost, paste a fresh cookie into the secret.

2. Open the dashboard, log in with the password from the secret, and on the setup page enter the Garmin email and password. The 2FA code is asked for inline. Garmin rate-limits logins for hours if you retry, so get it right once. Hevy already shows as connected, from the key in the secret.

3. In Settings, set the timezone, set the sync start date to the day the watch started recording alongside Hevy, turn on *Enhance Watch Activities* and pick the *Merge* strategy, then press Save. Merge keeps the watch's activity and writes the Hevy sets into it. *Replace* uploads a copy and deletes the watch's, which loses Training Effect and leaves a duplicate on Strava. A start date earlier than the watch recordings uploads every older Hevy workout as a new activity, and Garmin forwards each one to Strava.

4. Wait for the next hourly run of hevy-trainer-sync, or trigger one. The Routines page then shows the `Hevy Trainer` folder with the routines already synced, and the next one shows up as today's workout on the watch.

5. In Hevy, disconnect Strava (Profile → Settings → Integrations). Garmin Connect stays connected to Strava, otherwise every workout lands there twice.

## At the gym

Press the activity button, pick Strength, say yes when the watch offers today's workout, and log the workout in Hevy on the phone as usual, starting and stopping both within a few minutes of each other. That's it. The [poller](resources/trainer-poll.yml) waits for the watch's recording to reach Garmin, however long the watch takes to sync, then has hevy2garmin merge into it. A session the watch didn't record stays in Hevy. The [CronJob](resources/cronjob.yml) is suspended: after two hours it uploads anything not yet merged, and Garmin posts that to Strava as a second activity. Don't press *Sync Now* in the dashboard for the same reason.

Trainer's next workout only changes when a session finishes or the weekly rotation runs, so the hourly [trainer sync](resources/trainer-sync.yml) has the watch current well before the next session. An exercise swapped in the Hevy app mid-workout isn't on the watch for that session; the merge still fixes Garmin Connect afterwards.
