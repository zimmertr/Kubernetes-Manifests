#!/bin/sh
set -e

FILTER_ACTIVITY="${FILTER_ACTIVITY:-Climbing}"
FILTER_TYPE="${FILTER_TYPE:-Trip}"
FILTER_CLIMBING_CATEGORY="${FILTER_CLIMBING_CATEGORY:-Basic Alpine,Rock Climb}"
SHEET_NAME="${SHEET_NAME:-Mountaineers Trips}"

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
  --filter-activity "$FILTER_ACTIVITY" \
  --filter-type "$FILTER_TYPE" \
  --filter-climbing-category "$FILTER_CLIMBING_CATEGORY" \
  --output-filename /data/urls_climbing.txt

log_block "Parsing URLs..."
python3 -m mountaineers_activity_scraper.cli \
  --mode scrape \
  --input-urls-filename /data/urls_climbing.txt \
  --output-destination google-sheets \
  --sheet "$SHEET_NAME" \
  --creds /data/google_cloud_credentials.json
