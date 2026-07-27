#!/bin/sh
# The blocking release gate. Deliberately deterministic: it asks the new pods
# only about themselves, so the decision to promote or abort never depends on
# whether a free third-party API happens to be up.
#
# The old gate posted a real /api/analyze through Overpass and Open-Meteo, which
# meant an upstream outage failed a release that was perfectly healthy. That
# test still runs (api-test.sh) but is now informational. This is what blocks.
#
# What it proves:
#   1. The experiment pods answer through the real ingress path (gateway, TLS,
#      VirtualService header routing), because the request is made exactly the
#      way api-test.sh made it.
#   2. They are a genuine released build. GET /api/version reports "dev" unless
#      the release workflow baked build args in, so a semver-shaped answer means
#      a real image, not a stray local build.
#   3. The app finished wiring itself up. /api/capabilities is served from the
#      same constants the request validators use, so a sane answer there means
#      the models imported and the routes registered.
#
#   HOST              Public hostname to request; TLS is validated against it.
#   CONNECT_TO        host:port curl physically connects to instead of resolving
#                     HOST, pointing in-cluster pods straight at the ingress
#                     gateway Service. Empty = resolve HOST normally.
#   HEADER            Extra request header. "experiment: true" steers the
#                     request to the experiment pods via the VirtualService.
#   EXPECTED_VERSION  Optional. When set, the reported version must match it
#                     exactly, which additionally proves the header route
#                     reached the NEW pods rather than the stable ones. When
#                     empty, any semver is accepted.

HOST="${HOST:-bluebirdforecast.com}"
CONNECT_TO="${CONNECT_TO:-}"
HEADER="${HEADER:-}"
EXPECTED_VERSION="${EXPECTED_VERSION:-}"

BODY=/tmp/response.json

# curlimages/curl carries no jq, so every assertion below is a grep against the
# compact JSON body.
fetch() {
  set -- curl -sS --max-time 20 -o "$BODY" -w '%{http_code}' "https://${HOST}$1"
  [ -n "$HEADER" ] && set -- "$@" -H "$HEADER"
  [ -n "$CONNECT_TO" ] && set -- "$@" --connect-to "${HOST}:443:${CONNECT_TO}"
  "$@"
}

fail() {
  echo "FAIL: $1"
  [ -s "$BODY" ] && { head -c 500 "$BODY"; echo; }
  exit 1
}

# ── 1. Build identity ────────────────────────────────────────────────────────
STATUS="$(fetch /api/version)"
[ "$STATUS" = "200" ] || fail "HTTP ${STATUS:-000} from /api/version"

if [ -n "$EXPECTED_VERSION" ]; then
  grep -qF "\"version\":\"${EXPECTED_VERSION}\"" "$BODY" \
    || fail "expected version ${EXPECTED_VERSION}, got something else"
  echo "OK: /api/version reports ${EXPECTED_VERSION}"
else
  # No expected value wired in yet, so assert the shape instead. This still
  # catches the case that matters most: an image built without release args
  # reports "dev" for every field and fails here.
  grep -qE '"version":"[0-9]+\.[0-9]+\.[0-9]+"' "$BODY" \
    || fail "/api/version did not report a semver (a \"dev\" build should never reach a release gate)"
  echo "OK: /api/version reports a released build"
fi
head -c 200 "$BODY"; echo

# ── 2. The app wired itself up ───────────────────────────────────────────────
STATUS="$(fetch /api/capabilities)"
[ "$STATUS" = "200" ] || fail "HTTP ${STATUS:-000} from /api/capabilities"

grep -q '"max_polygon_area_km2":' "$BODY" \
  || fail "/api/capabilities is missing its limits"
grep -q '"destination_types":\["' "$BODY" \
  || fail "/api/capabilities reported no destination types"

echo "OK: /api/capabilities reports limits and destination types"
head -c 200 "$BODY"; echo
exit 0
