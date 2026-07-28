#!/bin/sh
# Functional smoke test for a bluebird release, run by Argo Rollouts as a
# blocking canary gate before any user traffic shifts: POST a small,
# known-good polygon (Tiger Mountain, Issaquah WA, 8 named OSM peaks) to
# /api/analyze and require a real ranking back. Exercises the full path: Istio
# gateway, TLS, VirtualService header routing, FastAPI, Overpass, Open-Meteo.
#
#   HOST        Public hostname to request; TLS is validated against it.
#   CONNECT_TO  host:port curl physically connects to instead of resolving
#               HOST, pointing in-cluster pods straight at the ingress gateway
#               Service so external DNS/NAT reflection never matter.
#               Empty = resolve HOST normally.
#   HEADER      Extra request header. "experiment: true" steers the request to
#               the canary Service via the VirtualService's header-matched
#               route, bypassing the weighted stable route.

HOST="${HOST:-bluebirdforecast.com}"
CONNECT_TO="${CONNECT_TO:-}"
HEADER="${HEADER:-}"

# The API rejects windows outside the ~16-day forecast horizon, so the
# window must be computed at run time: now to +48h. busybox date needs the
# @epoch form; its -D %s parsing is broken.
START="$(date -u +%Y-%m-%dT%H:00:00Z)"
END="$(date -u -d "@$(( $(date -u +%s) + 172800 ))" +%Y-%m-%dT%H:00:00Z)"

BODY=/tmp/analyze-response.json

set -- curl -sS --max-time 90 -o "$BODY" -w '%{http_code}' \
  -H 'Content-Type: application/json' --data @- \
  "https://${HOST}/api/analyze"
[ -n "$HEADER" ] && set -- "$@" -H "$HEADER"
[ -n "$CONNECT_TO" ] && set -- "$@" --connect-to "${HOST}:443:${CONNECT_TO}"

HTTP_STATUS=$("$@" <<EOF
{
  "polygon": {
    "type": "Polygon",
    "coordinates": [[
      [-122.03, 47.44], [-121.91, 47.44], [-121.91, 47.53],
      [-122.03, 47.53], [-122.03, 47.44]
    ]]
  },
  "destination_type": "peak",
  "start_datetime": "${START}",
  "end_datetime": "${END}",
  "limit": 3
}
EOF
)

if [ "$HTTP_STATUS" != "200" ]; then
  echo "FAIL: HTTP ${HTTP_STATUS:-000} from https://${HOST}/api/analyze"
  [ -s "$BODY" ] && { head -c 500 "$BODY"; echo; }
  exit 1
fi

# A 200 says nothing about which upstream actually produced anything, so each
# stage is asserted separately and a failure names its own cause.
#
# curlimages/curl has no jq, so these are greps, and grep matches one line at a
# time. Every pattern must therefore match a SINGLE token: anything spanning two
# (like the old `"results":\[{`) breaks the moment the JSON is formatted
# differently, and reads as a real outage when it does.
assert() {
  if grep -qE "$2" "$BODY"; then
    echo "  ok: $1"
    return 0
  fi
  echo "FAIL: $1"
  echo "  no match for: $2"
  head -c 500 "$BODY"; echo
  exit 1
}

# Not asserted on purpose: a peak count (OSM data shifts under us) or AQI
# (best-effort, legitimately null past its shorter horizon).
assert "Overpass discovered candidates"       '"total_queried": ?[1-9][0-9]*'
assert "the ranking returned peak rows"       '"type": ?"peak"'
assert "Open-Meteo attached a real forecast"  '"precip_total_in": ?-?[0-9]'

echo "OK: /api/analyze returned ranked peaks for Tiger Mountain"
head -c 300 "$BODY"; echo
exit 0
