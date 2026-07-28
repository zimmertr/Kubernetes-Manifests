#!/bin/sh
# Identity gate for a bluebird release, run by Argo Rollouts alongside the
# functional gate (api-test.sh). Proves three things api-test.sh cannot, since
# that test passes just as happily against the stable pods:
#
#   1. The canary answers through the real ingress path, so a VirtualService
#      header-routing misfire fails here.
#   2. It is a genuine released build. /api/version reports "dev" unless the
#      release workflow baked build args in.
#   3. It finished wiring itself up. /api/capabilities is served from the same
#      constants the request validators use.
#
#   HOST              Public hostname to request; TLS is validated against it.
#   CONNECT_TO        host:port curl physically connects to instead of resolving
#                     HOST, pointing in-cluster pods straight at the ingress
#                     gateway Service. Empty = resolve HOST normally.
#   HEADER            Extra request header. "experiment: true" steers the
#                     request to the canary Service via the VirtualService's
#                     header-matched route, bypassing the weighted stable route.
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
  # Shape only, which still catches what matters most: an image built without
  # release args reports "dev" and fails here.
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
