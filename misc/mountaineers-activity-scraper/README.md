# Mountaineers Activity Scraper

A CronJob that runs the [Mountaineers Activity Scraper](https://github.com/zimmertr/Mountaineers-Activity-Scraper) once a day and exports to Google Sheets.

It needs a Google Cloud service account key. Follow the scraper's [Google Sheets Setup](https://github.com/zimmertr/Mountaineers-Activity-Scraper#google-sheets-setup), share the sheet named in [resources/cronjob.yml](resources/cronjob.yml) with the service account, and save the key as `files/google_cloud_credentials.json`. It's gitignored.
