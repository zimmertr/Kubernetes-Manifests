#!/usr/bin/env bash
# Tests the model downloader's pruning in its own image, with a stub llama
# binary and a scratch /models, so no cluster or network is involved:
#
#   docker run --rm \
#     -v "$PWD/files/model-downloader.sh:/scripts/model-downloader.sh:ro" \
#     -v "$PWD/tests/model-downloader-test.sh:/tests/test.sh:ro" \
#     --entrypoint bash ghcr.io/ggml-org/llama.cpp:light-b11541 /tests/test.sh
#
# Each phase edits the config, waits for the downloader to react, and asserts
# what's on /models afterwards. Markers are aged with touch, since the grace
# period is measured from their mtime.
set -euo pipefail

export CHECK_INTERVAL=1 REVIEW_INTERVAL=2 PRUNE_AFTER_HOURS=72 LLAMA_CACHE=/models
LOG=/tmp/downloader.log
MODELS=/models
HF=$MODELS/hf
MARKERS=$MODELS/.cache/unused

# Stands in for `llama download`: puts a file in the cache the way llama.cpp
# does, named after its SHA-256, and prints its snapshot path. A repo under
# the user "broken" fails, to test the failure guard.
cat > /app/llama <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
repo=""; file=""
while (( $# )); do
  case $1 in
    -hf) repo=$2; shift 2 ;;
    -hff) file=$2; shift 2 ;;
    *) shift ;;
  esac
done
quant=${repo#*:}; repo=${repo%%:*}
[[ $repo == broken/* ]] && { echo "stub: cannot download $repo" >&2; exit 1; }
[[ -n $file ]] || file="${repo#*/}-$quant.gguf"
dir=/models/models--${repo%/*}--${repo#*/}
content="weights of $repo $file"
hash=$(printf '%s' "$content" | sha256sum | cut -d' ' -f1)
mkdir -p "$dir/blobs" "$dir/snapshots/main"
printf '%s' "$content" > "$dir/blobs/$hash"
ln -sf "../../blobs/$hash" "$dir/snapshots/main/$file"
echo "$dir/snapshots/main/$file"
STUB
chmod +x /app/llama

mkdir -p /config /extra "$MODELS"
pass=0
assert() {
  local description=$1
  shift
  if "$@"; then
    pass=$((pass + 1))
    echo "  ok: $description"
  else
    echo "FAILED: $description" >&2
    echo "--- downloader log:" >&2
    cat "$LOG" >&2
    exit 1
  fi
}
logged() { grep --quiet --fixed-strings "$1" "$LOG"; }
wait_for() {
  local n=0
  until grep --quiet --fixed-strings "$1" "$LOG"; do
    sleep 0.2
    n=$((n + 1))
    (( n < 150 )) || { echo "timed out waiting for: $1" >&2; cat "$LOG" >&2; exit 1; }
  done
}
# The downloader reacts to a config change by logging a fresh "All models
# present"; counting them tells one check from the next.
checks() { grep --count --fixed-strings 'All models present' "$LOG" || true; }
wait_for_check() {
  local before=$1 n=0
  until (( $(checks) > before )); do
    sleep 0.2
    n=$((n + 1))
    (( n < 150 )) || { echo "timed out waiting for a check" >&2; cat "$LOG" >&2; exit 1; }
  done
}
age_markers() { touch --date="-$1 hours" "$MARKERS"/*; }
stale_blob=$MODELS/models--a--one/blobs/$(printf 'x' | sha256sum | cut -d' ' -f1)

echo "phase 1: unused things are reported and dated, nothing is deleted"
cat > /config/config.yaml <<'EOF'
models:
  "one":
    cmd: |
      llama-server
      -hf a/one:Q4
  "two":
    cmd: |
      sd-server --diffusion-model /models/hf/b/two/two.gguf
EOF
mkdir -p "$MODELS/models--a--one/blobs" "$MODELS/models--a--one/snapshots/old" \
  "$MODELS/models--c--three/blobs" "$HF/d/four"
printf 'x' > "$stale_blob"
ln -s "../../blobs/$(basename "$stale_blob")" "$MODELS/models--a--one/snapshots/old/stale.gguf"
printf 'y' > "$MODELS/models--c--three/blobs/$(printf 'y' | sha256sum | cut -d' ' -f1)"
ln -s "$MODELS/models--c--three/blobs/nothing" "$HF/d/four/old.gguf"
printf 'notes' > "$MODELS/local-notes.txt"

bash /scripts/model-downloader.sh 2> "$LOG" &
downloader=$!
trap 'kill "$downloader" 2> /dev/null' EXIT
wait_for 'All models present'
assert "the stale blob has a marker and is still there" test -e "$(printf '%s' "$stale_blob" | sha256sum | cut -c1-32 | sed "s|^|$MARKERS/|")" -a -e "$stale_blob"
assert "the undeclared repo is dated for deletion" logged "Not used by any config: $MODELS/models--c--three,"
assert "the stale /models/hf link is dated for deletion" logged "Not used by any config: $HF/d/four/old.gguf,"
assert "the deletion date is logged" logged "Deleting it on $(date --date='+72 hours' +%F)"
assert "a hand-placed top-level file is reported but has no marker" logged "not managed here: $MODELS/local-notes.txt"
assert "declared files are not reported" bash -c "! grep -q 'Not used by any config: $MODELS/models--a--one,' $LOG"
assert "three markers exist" test "$(ls "$MARKERS" | wc -l)" -eq 3

echo "phase 2: after the grace period, unused things are deleted"
age_markers 80
wait_for 'Deleted '
sleep 1
assert "the stale blob is gone" test ! -e "$stale_blob"
assert "the stale blob's snapshot link is gone" test ! -L "$MODELS/models--a--one/snapshots/old/stale.gguf"
assert "the empty snapshot directory is gone" test ! -d "$MODELS/models--a--one/snapshots/old"
assert "the undeclared repo is gone" test ! -d "$MODELS/models--c--three"
assert "the stale /models/hf link is gone" test ! -L "$HF/d/four/old.gguf"
assert "the declared model is still there" test -e "$MODELS/models--a--one/snapshots/main/one-Q4.gguf"
assert "the declared /models/hf file is still there" test -L "$HF/b/two/two.gguf"
assert "the hand-placed file is still there" test -e "$MODELS/local-notes.txt"
assert "no markers remain" test "$(ls "$MARKERS" | wc -l)" -eq 0
assert "the deletion was logged with hours unused" logged "unused for 80h"

echo "phase 3: a model declared again during its grace period is kept"
before=$(checks)
cat > /config/config.yaml <<'EOF'
models:
  "two":
    cmd: |
      sd-server --diffusion-model /models/hf/b/two/two.gguf
EOF
wait_for_check "$before"
assert "the removed model is dated for deletion" logged "Not used by any config: $MODELS/models--a--one,"
age_markers 48
before=$(checks)
cat > /config/config.yaml <<'EOF'
models:
  "one":
    cmd: |
      llama-server
      -hf a/one:Q4
  "two":
    cmd: |
      sd-server --diffusion-model /models/hf/b/two/two.gguf
EOF
wait_for_check "$before"
assert "its return is logged" logged "Used again, so no longer to be deleted: $MODELS/models--a--one"
assert "its marker is gone" test "$(ls "$MARKERS" | wc -l)" -eq 0
assert "the model is still there" test -e "$MODELS/models--a--one/snapshots/main/one-Q4.gguf"

echo "phase 4: a config that declares nothing deletes nothing"
before=$(checks)
printf 'models: {}\n' > /config/config.yaml
wait_for_check "$before"
assert "the empty config is called out" logged "declare no models, so nothing on $MODELS is reviewed"
assert "no markers were created" test "$(ls "$MARKERS" | wc -l)" -eq 0
assert "everything is still there" test -e "$MODELS/models--a--one/snapshots/main/one-Q4.gguf" -a -L "$HF/b/two/two.gguf"

echo "phase 5: a failed download blocks deletion"
before=$(checks)
cat > /config/config.yaml <<'EOF'
models:
  "two":
    cmd: |
      sd-server --diffusion-model /models/hf/b/two/two.gguf
EOF
wait_for_check "$before"
assert "the dropped model is dated for deletion" test "$(ls "$MARKERS" | wc -l)" -eq 1
age_markers 80
cat > /config/config.yaml <<'EOF'
models:
  "two":
    cmd: |
      sd-server --diffusion-model /models/hf/b/two/two.gguf
  "bad":
    cmd: |
      llama-server
      -hf broken/model:Q4
EOF
wait_for 'Failed to download broken/model:Q4'
wait_for 'Retrying the failed downloads'
sleep 3
assert "nothing was deleted while a download fails" test -e "$MODELS/models--a--one/snapshots/main/one-Q4.gguf"
assert "no deletion was logged in this phase" test "$(grep --count 'Deleted ' "$LOG")" -eq 3

echo "all $pass assertions passed"
