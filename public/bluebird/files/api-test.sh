#!/bin/sh
# Functional smoke test for a bluebird release, run by Argo Rollouts as a
# blocking canary gate before any user traffic shifts: POST a small,
# known-good polygon (Tiger Mountain, Issaquah WA, 8 named OSM peaks) to
# /api/analyze and require a real ranking back. Exercises the full path: Istio
# gateway, TLS, VirtualService header routing, FastAPI, Overpass, Open-Meteo.
#
# This gate blocks on purpose. A release that cannot serve a real analysis is
# not healthy, whatever the reason, so an upstream failure aborts the deploy
# rather than shipping something that answers nothing.
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

# An analysis passes through three upstreams in sequence, and a 200 alone says
# nothing about which of them actually produced anything. Assert each stage
# separately so a failed gate names its own cause instead of leaving someone to
# diff the payload by hand.
#
# curlimages/curl ships no jq, so these are greps, which makes formatting a
# trap. The previous assertion was `"results":\[{`: it silently required FastAPI
# to emit no space between the bracket and the brace, so a serializer change
# would have read as a real outage. Widening that to allow a space is not enough
# either, because grep matches one line at a time and pretty-printed JSON puts a
# newline there instead.
#
# So every pattern below matches a SINGLE token that formatting cannot split.
# That is why "the ranking produced rows" is asserted as `"type":"peak"` rather
# than by looking at the array punctuation: it survives any formatting, and it
# proves the rows are the destination type we actually asked for.
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

# Deliberately not asserted: a peak count (OSM data changes under us, and a
# renamed summit is not a release problem) or AQI (best-effort by design, and
# legitimately null past its shorter horizon).
assert "Overpass discovered candidates"       '"total_queried": ?[1-9][0-9]*'
assert "the ranking returned peak rows"       '"type": ?"peak"'
assert "Open-Meteo attached a real forecast"  '"precip_total_in": ?-?[0-9]'

echo "OK: /api/analyze returned ranked peaks for Tiger Mountain"
head -c 300 "$BODY"; echo
exit 0
