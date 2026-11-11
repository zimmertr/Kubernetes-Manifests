# hevy-garmin-sync

[hevy-garmin-sync](https://github.com/zimmertr/hevy-garmin-sync) puts my Hevy routines, and Hevy Trainer's workouts, on my Garmin watch as strength workouts. Garmin forwards what the watch records to Strava the moment it syncs, and Strava keeps that version, so the planned workout on the watch is what makes Strava right. It reads Hevy and writes Garmin, nothing else.

It replaced hevy2garmin and hevy-trainer-sync. Nothing merges Hevy's sets into the Garmin activity afterwards any more.

It's one pod from the project's own Helm chart. Its release job bumps the chart version in [kustomization.yml](kustomization.yml) after every release, through a PR that merges itself. There's no dashboard and nothing is exposed: the log is the only place to look.

## Setup

1. Make a Hevy API key at https://hevy.com/settings?developer.

2. Sign in to Garmin once, at home, and keep the long value it prints. The password is used once and saved nowhere. Garmin rate-limits logins for hours if you retry, so get it right once.

   ```bash
   docker run --rm -it ghcr.io/zimmertr/hevy-garmin-sync:0.3.0 login
   ```

3. For Hevy Trainer, open a private browser window, sign in at hevy.com, and copy the whole value of the `auth2.0-token` cookie (DevTools → Application → Cookies). Close the window without logging out.

4. Create the secret from the root README's [Secrets and Volumes](../../README.md#secrets-and-volumes). The pod starts as soon as the secret exists.

The Garmin token and the Hevy session both rotate. The pod reads them from the secret on its first start and keeps the current ones on its volume after that. If the volume is ever lost, or Garmin or Hevy signs it out, the log says which value it needs. Get a fresh one with step 2 or 3, delete the secret, create it again, and restart the pod: a value that changed in the secret replaces the one on the volume.

## At the gym

Press the activity button, pick Strength, and pick the workout the watch offers for today. Log in Hevy on the phone as usual: Trainer's next weights come from what's logged there, and they're in Garmin Connect about a minute after the workout is saved. The watch gets them at its next sync with the phone.
