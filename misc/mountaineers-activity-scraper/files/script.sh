#!/bin/sh
set -e

timestamp() {
  date '+%Y-%m-%d %H:%M:%S'
}

log_block() {
  echo ""
  echo "----------------------------------------------------------------------"
  echo "[$(timestamp)] $1"
  echo "----------------------------------------------------------------------"
}

log_block "Collecting URLs..."

python3 -m mountaineers_activity_scraper.cli \
  --mode collect \
  --filter-activity Climbing \
  --filter-type Trip \
  --filter-climbing-category "Basic Alpine","Rock Climb" \
  --output-filename /data/urls_climbing.txt

log_block "Parsing URLs..."

python3 -m mountaineers_activity_scraper.cli \
  --mode scrape \
  --input-urls-filename /data/urls_climbing.txt \
  --output-destination google-sheets \
  --sheet "Mountaineers Trips" \
  --creds /data/google_cloud_credentials.json
