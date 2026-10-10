# Mountaineers Activity Scraper

1. Follow the scraper's [Google Sheets Setup](https://github.com/zimmertr/Mountaineers-Activity-Scraper#google-sheets-setup) to create a project, enable the Sheets and Drive APIs, and create a service account with a JSON key.

2. Share the `Mountaineers Trips` sheet with the service account's `client_email` as an editor.

3. Save the key as `files/google_cloud_credentials.json`. It's gitignored, and [the example](files/google_cloud_credentials.json.example) shows its shape. Then create the secret from the root README's [Secrets and Volumes](../../README.md#secrets-and-volumes).
