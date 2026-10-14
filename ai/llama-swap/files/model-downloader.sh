#!/usr/bin/env bash
# Downloads every model llama-swap's config names, and any it gains later. It
# runs beside llama-swap rather than before it, so llama-swap serves the models
# already on /models while new ones download.
#
# The config names a model in one of two ways:
#
#   -hf <user>/<repo>:<quant>
#       A language model. llama-server finds it in llama.cpp's Hugging Face
#       cache by itself.
#
#   --<flag> /models/hf/<user>/<repo>/<file>
#       A single file, for sd-server, which can't read that cache. The path is
#       a symlink to the file's place in the cache, kept stable while the
#       cache's own path changes with every commit to the repo.
#
# llama.cpp's downloader fetches both into its cache, skips files it already
# has, resumes interrupted ones, and fetches a file again when Hugging Face
# publishes a new version. It names each file after its SHA-256, which this
# checks once per file, since llama.cpp never does.
#
# It also prunes what no config uses any more, after a grace period: the first
# time a check finds a file unused it records the date and warns, on every
# later check it warns again with the deletion date, and once the file has
# been unused for PRUNE_AFTER_HOURS it deletes it. A file declared again in
# the meantime is forgotten. The grace period means a model taken out of the
# config by mistake, or a ConfigMap that's briefly missing, costs nothing.
# Only llama.cpp's cache and /models/hf are pruned; anything else on /models
# is reported and left alone, since that's where files placed by hand live.
# Nothing is pruned after a check in which a download failed, or when the
# configs declare no models at all, because that's what a broken config looks
# like.
#
# Set LOG_LEVEL=debug to also log each check that finds nothing to do.

set -uo pipefail
shopt -s nullglob

readonly MODELS_DIR=/models
readonly HF_FILES_DIR=/models/hf
readonly VERIFIED_DIR=/models/.cache/verified
readonly UNUSED_DIR=/models/.cache/unused  # one marker per unused path, dated when first seen
readonly LLAMA_OUTPUT=/tmp/llama-download.log
readonly CHECK_INTERVAL=${CHECK_INTERVAL:-60}       # seconds between checks of the config
readonly REVIEW_INTERVAL=${REVIEW_INTERVAL:-3600}  # seconds between reviews of unused files when the config is unchanged
readonly PROGRESS_INTERVAL=5  # seconds between progress reports
readonly SIZES_DIR=$MODELS_DIR/.cache/sizes  # expected size of each blob, by its SHA-256, for the progress reports
readonly PRUNE_AFTER_HOURS=${PRUNE_AFTER_HOURS:-72}
readonly LOG_LEVEL=${LOG_LEVEL:-info}

# Every path on /models the configs use, filled in by each check, and how
# many models and files the configs declared.
declare -A USED=()
DECLARED=0

# Logs go to stderr, because functions hand their results over on stdout.
# %(...)T is bash's own strftime, so logging doesn't fork date, and the
# container's clock is UTC.
log() {
  local level=$1
  shift
  printf '%(%Y-%m-%dT%H:%M:%SZ)T %s\t| %s\n' -1 "$level" "$*" >&2
}

debug() {
  if [[ $LOG_LEVEL == debug ]]; then
    log DEBUG "$@"
  fi
}

info() {
  log INFO "$@"
}

warn() {
  log WARN "$@"
}

error() {
  log ERROR "$@"
}

# Only lines that start with the flag, so a comment that mentions one doesn't
# count.
declared_hf_models() {
  grep --no-filename --extended-regexp '^[[:space:]]*-hf[[:space:]]' "$@" |
    awk '{ print $2 }' | sort --unique
}

# Any path under /models/hf/ outside a comment, whichever flag it follows,
# since sd-server's flags include digits and underscores (--t5xxl,
# --llm_vision).
declared_hf_files() {
  grep --no-filename --invert-match '^[[:space:]]*#' "$@" |
    grep --only-matching --extended-regexp "$HF_FILES_DIR/[^[:space:]\"']+" | sort --unique
}

# Paths in the cache encode the repo as models--<user>--<repo>, and the file's
# path in the repo follows snapshots/<commit>/.
repo_name() {
  local repo=${1#"$MODELS_DIR"/models--}

  repo=${repo%%/*}
  printf '%s\n' "${repo//--//}"
}

cached_file_name() {
  printf '%s/%s\n' "$(repo_name "$1")" "${1#*/snapshots/*/}"
}

gigabytes() {
  local tenths=$(($1 / 100000000))

  printf '%d.%d GB\n' $((tenths / 10)) $((tenths % 10))
}

# Checks a cached file against the SHA-256 its blob is named after, and
# discards both if they differ, so the next download fetches it again. A
# marker records each blob that passed, so it's hashed only once.
verify() {
  local cached=$1
  local blob hash name started

  blob=$(readlink --canonicalize-existing "$cached") || return 1
  hash=$(basename "$blob")

  # Small files that aren't stored in LFS are named after a git SHA-1 of
  # their contents instead, and aren't worth checking.
  [[ ${#hash} -eq 64 ]] || return 0
  [[ -e $VERIFIED_DIR/$hash ]] && return 0

  name=$(cached_file_name "$cached")
  info "Verifying $name, $(gigabytes "$(stat --format=%s "$blob")")"
  started=$SECONDS
  if [[ $(sha256sum "$blob" | cut --delimiter=' ' --fields=1) == "$hash" ]]; then
    touch "$VERIFIED_DIR/$hash"
    rm --force "$SIZES_DIR/$hash"
    info "Verified $name in $((SECONDS - started))s"
    return 0
  fi

  error "Checksum mismatch, discarding $name"
  rm --force "$blob" "$cached"
  return 1
}

# Runs llama.cpp's downloader with the given arguments, verifies every file it
# resolved, and prints their paths in the cache. llama.cpp's own messages are
# logged as errors when it fails, and only at debug level otherwise.
download() {
  local output cached line level=debug

  output=$(/app/llama download "$@" 2> "$LLAMA_OUTPUT") || level=error
  while IFS= read -r line; do
    "$level" "llama.cpp: $line"
  done < "$LLAMA_OUTPUT"
  [[ $level == debug ]] || return 1

  while IFS= read -r cached; do
    [[ -n $cached ]] || continue
    verify "$cached" || return 1
  done <<< "$output"
  printf '%s\n' "$output"
}

# Records a file in llama.cpp's cache as used: the path the config resolves
# to, the blob it points to, and the repo's directory.
mark_used() {
  local cached=$1

  USED[$cached]=1
  USED[$(readlink --canonicalize-existing "$cached")]=1
  USED[${cached%%/snapshots/*}]=1
}

# Writes the expected size of each blob a download will produce, so the
# progress reports can say how far along it is. Best effort: Hugging Face's
# answer is what llama.cpp itself goes by, and without it the report simply
# has no total.
note_sizes() {
  local hash bytes
  mkdir --parents "$SIZES_DIR"
  while read -r hash bytes; do
    # A manifest also lists the chat template and parameters, a few bytes each.
    [[ ${#hash} -eq 64 && ${bytes:-0} -ge 1000000 ]] || continue
    printf '%s\n' "$bytes" > "$SIZES_DIR/$hash"
  done
  return 0
}

hf_get() {
  curl --silent --fail --location --max-time 30 --user-agent llama-cpp \
    ${HF_TOKEN:+--header "Authorization: Bearer $HF_TOKEN"} "$@"
}

# A model's manifest lists every blob with its digest and size. The digest is
# the blob's file name in the cache.
note_model_sizes() {
  local model=$1 tag=latest
  [[ $model == *:* ]] && tag=${model#*:}
  hf_get "https://huggingface.co/v2/${model%%:*}/manifests/$tag" 2> /dev/null |
    tr --delete ' \n' |
    grep --only-matching --extended-regexp '"digest":"sha256:[0-9a-f]{64}"|"size":[0-9]+' |
    sed --expression 's/"digest":"sha256://' --expression 's/"size"://' --expression 's/"//g' |
    paste --delimiters=' ' - - |
    note_sizes || true
}

# A file's headers carry the same two facts for its one blob.
note_file_sizes() {
  hf_get --head "https://huggingface.co/$1/resolve/main/$2" 2> /dev/null |
    tr --delete '\r' |
    awk 'tolower($1) == "x-linked-etag:" { gsub(/"/, "", $2); hash = $2 }
         tolower($1) == "x-linked-size:" { bytes = $2 }
         END { if (hash != "") print hash, bytes }' |
    note_sizes || true
}

download_hf_model() {
  local model=$1
  local output cached

  info "Checking $model"
  note_model_sizes "$model"
  output=$(download -hf "$model") || return 1
  while IFS= read -r cached; do
    mark_used "$cached"
    info "Ready: $(cached_file_name "$cached") at $cached"
  done <<< "$output"
}

download_hf_file() {
  local path=$1
  local user repo file cached

  IFS=/ read -r user repo file <<< "${path#"$HF_FILES_DIR"/}"
  info "Checking $user/$repo/$file"
  note_file_sizes "$user/$repo" "$file"
  cached=$(download -hf "$user/$repo" -hff "$file" --no-mmproj) || return 1

  if [[ $(readlink "$path") != "$cached" ]]; then
    mkdir --parents "$(dirname "$path")"
    # Renaming a new link over the old path swaps it in one step, so sd-server
    # never finds the file missing.
    ln --symbolic --force "$cached" "$path.new" || return 1
    mv --no-target-directory "$path.new" "$path" || return 1
  fi
  mark_used "$cached"
  USED[$path]=1
  info "Ready: $user/$repo/$file at $path -> $cached"
}

# Downloads whatever the given config files name that isn't on /models yet.
# One failure doesn't stop the rest, and the return status says whether any
# download failed.
download_declared_models() {
  local -a models files
  local model path failed=0

  USED=()
  mapfile -t models < <(declared_hf_models "$@")
  mapfile -t files < <(declared_hf_files "$@")
  DECLARED=$((${#models[@]} + ${#files[@]}))

  for model in "${models[@]}"; do
    download_hf_model "$model" || { error "Failed to download $model"; failed=1; }
  done
  for path in "${files[@]}"; do
    download_hf_file "$path" || { error "Failed to download $path"; failed=1; }
  done

  return "$failed"
}

size_of() {
  du --summarize --human-readable "$1" | cut --fields=1
}

# The marker that records when a path was first found unused. Its name is a
# hash of the path, since paths contain slashes, and its content is the path.
marker_for() {
  printf '%s/%s\n' "$UNUSED_DIR" "$(printf '%s' "$1" | sha256sum | cut --characters=1-32)"
}

# Deletes an unused path and its marker. A blob's snapshot links would dangle
# without it, so they go too.
delete_unused() {
  local path=$1

  if [[ $path == */blobs/* ]]; then
    find "${path%%/blobs/*}/snapshots" -type l -lname "*/blobs/$(basename "$path")" -delete
  fi
  rm --recursive --force "$path" && rm --force "$(marker_for "$path")"
}

# Warns about an unused path, and deletes it once it has been unused for the
# whole grace period.
consider_unused() {
  local path=$1
  local marker size unused_hours

  marker=$(marker_for "$path")
  size=$(size_of "$path")
  if [[ ! -e $marker ]]; then
    printf '%s\n' "$path" > "$marker"
    warn "Not used by any config: $path, $size." \
      "Deleting it on $(date --date="+$PRUNE_AFTER_HOURS hours" +%F) unless a config uses it again"
    return
  fi

  unused_hours=$(( ($(date +%s) - $(stat --format=%Y "$marker")) / 3600 ))
  if (( unused_hours >= PRUNE_AFTER_HOURS )); then
    delete_unused "$path" && info "Deleted $path, $size, unused for ${unused_hours}h"
  else
    warn "Not used by any config: $path, $size, unused for ${unused_hours}h." \
      "Deleting it on $(date --date="+$((PRUNE_AFTER_HOURS - unused_hours)) hours" +%F) unless a config uses it again"
  fi
}

# Reviews everything on /models that the last check didn't mark as used:
# prunes what's inside llama.cpp's cache and /models/hf, reports the rest.
# Only meaningful after a check in which every download succeeded, since a
# failed one leaves USED incomplete.
review_unused() {
  local entry marker path

  mkdir --parents "$UNUSED_DIR"

  # The glob skips .cache, which holds the shader cache and the markers.
  for entry in "$MODELS_DIR"/*; do
    [[ $entry == "$HF_FILES_DIR" || -n ${USED[$entry]:-} ]] && continue
    if [[ $entry == "$MODELS_DIR"/models--* ]]; then
      consider_unused "$entry"
    else
      warn "Not used by any config, and not managed here: $entry, $(size_of "$entry")"
    fi
  done

  # Within a repo still in use: an old version of a file, a quant the config
  # no longer names, or an abandoned partial download.
  for entry in "$MODELS_DIR"/models--*/blobs/*; do
    if [[ -n ${USED[${entry%%/blobs/*}]:-} && -z ${USED[$entry]:-} ]]; then
      consider_unused "$entry"
    fi
  done

  if [[ -d $HF_FILES_DIR ]]; then
    while IFS= read -r -d '' entry; do
      [[ -n ${USED[$entry]:-} ]] || consider_unused "$entry"
    done < <(find "$HF_FILES_DIR" \( -type f -o -type l \) -print0)
  fi

  # Forget paths that a config uses again, or that are gone.
  for marker in "$UNUSED_DIR"/*; do
    path=$(< "$marker")
    if [[ -n ${USED[$path]:-} ]]; then
      info "Used again, so no longer to be deleted: $path"
      rm --force "$marker"
    elif [[ ! -e $path && ! -L $path ]]; then
      rm --force "$marker"
    fi
  done

  # Deleting leaves empty snapshot and /models/hf directories behind.
  for entry in "$MODELS_DIR"/models--* "$HF_FILES_DIR"; do
    [[ -d $entry ]] && find "$entry" -mindepth 1 -type d -empty -delete
  done
}

# llama.cpp shows no progress without a terminal, so this reports every file
# still downloading: its size so far, and its rate since the last report.
report_progress() {
  local -A last_size=() size=()
  local file bytes total progress

  while sleep "$PROGRESS_INTERVAL"; do
    size=()
    while IFS= read -r -d '' file; do
      # The download may have finished since find listed it.
      bytes=$(stat --format=%s "$file" 2> /dev/null) || continue
      size[$file]=$bytes
      # The blob is named after its SHA-256, which is how its size was noted.
      total=$(cat "$SIZES_DIR/$(basename "$file" .downloadInProgress)" 2> /dev/null) || total=""
      if [[ -n $total ]]; then
        progress="$(gigabytes "$bytes") of $(gigabytes "$total"), $((bytes * 100 / total))%"
      else
        progress=$(gigabytes "$bytes")
      fi
      if [[ -n ${last_size[$file]:-} ]]; then
        info "Downloading $(repo_name "$file"): $progress," \
          "$(((bytes - last_size[$file]) / PROGRESS_INTERVAL / 1000000)) MB/s"
      else
        info "Downloading $(repo_name "$file") to $file: $progress"
      fi
    done < <(find "$MODELS_DIR" -name '*.downloadInProgress' -print0)

    # Remember only the files still downloading, so one that starts over
    # under the same name isn't compared with its old size.
    last_size=()
    for file in "${!size[@]}"; do
      last_size[$file]=${size[$file]}
    done
  done
}

# Runs the review when the last check downloaded everything it needed and the
# configs declared something, so a broken config never looks like an empty one.
review_if_safe() {
  if (( DECLARED == 0 )); then
    warn "The configs declare no models, so nothing on $MODELS_DIR is reviewed for deletion"
  else
    review_unused
  fi
}

main() {
  local -a configs
  local checksum downloaded_checksum="" last_review=0

  mkdir --parents "$VERIFIED_DIR"
  report_progress &
  local reporter=$!
  trap 'kill "$reporter" 2> /dev/null; exit 0' TERM INT

  while true; do
    # Read afresh each time: Kubernetes updates the mounted ConfigMaps in
    # place, and the optional extra one can appear while the pod runs.
    configs=(/config/*.yaml /extra/*.yaml /extra/*.yml)
    checksum=$(cat "${configs[@]}" | sha256sum)

    if [[ $checksum != "$downloaded_checksum" ]]; then
      info "Checking the models in ${configs[*]}"
      if download_declared_models "${configs[@]}"; then
        downloaded_checksum=$checksum
        review_if_safe
        last_review=$SECONDS
        info "All models present, $(size_of "$MODELS_DIR") on $MODELS_DIR." \
          "Checking the config for changes every ${CHECK_INTERVAL}s"
      else
        warn "Retrying the failed downloads in ${CHECK_INTERVAL}s"
      fi
    elif (( SECONDS - last_review >= REVIEW_INTERVAL )); then
      # Grace periods run out between config changes too.
      review_if_safe
      last_review=$SECONDS
    else
      debug "No change to ${configs[*]}"
    fi

    # Waiting on a background sleep lets SIGTERM stop the pod straight away.
    sleep "$CHECK_INTERVAL" &
    wait $!
  done
}

main
