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

set -uo pipefail
shopt -s nullglob

readonly MODELS_DIR=/models
readonly HF_FILES_DIR=/models/hf
readonly VERIFIED_DIR=/models/.cache/verified
readonly CHECK_INTERVAL=60    # seconds between checks of the config
readonly PROGRESS_INTERVAL=30 # seconds between progress reports

# Logs go to stderr, because functions hand their results over on stdout.
log() {
  printf '%s\n' "$*" >&2
}

# Both match only lines that start with the flag, so a comment that mentions
# one doesn't count.
declared_hf_models() {
  grep --no-filename --extended-regexp '^[[:space:]]*-hf[[:space:]]' "$@" |
    awk '{ print $2 }' | sort --unique
}

declared_hf_files() {
  grep --no-filename --extended-regexp "^[[:space:]]*--[a-z-]+[[:space:]]+$HF_FILES_DIR/" "$@" |
    awk '{ print $2 }' | sort --unique
}

# Checks a cached file against the SHA-256 its blob is named after, and
# discards both if they differ, so the next download fetches it again. A
# marker records each blob that passed, so it's hashed only once.
verify() {
  local cached=$1
  local blob hash

  blob=$(readlink --canonicalize-existing "$cached") || return 1
  hash=$(basename "$blob")

  # Small files that aren't stored in LFS are named after a git SHA-1 of
  # their contents instead, and aren't worth checking.
  [[ ${#hash} -eq 64 ]] || return 0
  [[ -e $VERIFIED_DIR/$hash ]] && return 0

  log "Verifying $(cache_name "$blob")"
  if [[ $(sha256sum "$blob" | cut --delimiter=' ' --fields=1) == "$hash" ]]; then
    touch "$VERIFIED_DIR/$hash"
    return 0
  fi

  log "Checksum mismatch, discarding $(cache_name "$blob")"
  rm --force "$blob" "$cached"
  return 1
}

# Runs llama.cpp's downloader with the given arguments, verifies every file it
# resolved, and prints their paths in the cache.
download() {
  local output cached

  output=$(/app/llama download "$@") || return 1
  while IFS= read -r cached; do
    [[ -n $cached ]] || continue
    verify "$cached" || return 1
  done <<< "$output"
  printf '%s\n' "$output"
}

download_hf_model() {
  local model=$1

  log "Checking $model"
  download -hf "$model" > /dev/null
}

download_hf_file() {
  local path=$1
  local user repo file cached

  IFS=/ read -r user repo file <<< "${path#"$HF_FILES_DIR"/}"
  log "Checking $user/$repo/$file"
  cached=$(download -hf "$user/$repo" -hff "$file" --no-mmproj) || return 1

  [[ $(readlink "$path") == "$cached" ]] && return 0
  mkdir --parents "$(dirname "$path")"
  # Renaming a new link over the old path swaps it in one step, so sd-server
  # never finds the file missing.
  ln --symbolic --force "$cached" "$path.new" && mv --no-target-directory "$path.new" "$path"
}

# Downloads whatever the given config files name that isn't on /models yet.
# One failure doesn't stop the rest, and the return status says whether any
# download failed.
download_declared_models() {
  local -a models files
  local model path failed=0

  mapfile -t models < <(declared_hf_models "$@")
  mapfile -t files < <(declared_hf_files "$@")

  for model in "${models[@]}"; do
    download_hf_model "$model" || { log "Failed to download $model"; failed=1; }
  done
  for path in "${files[@]}"; do
    download_hf_file "$path" || { log "Failed to download $path"; failed=1; }
  done

  return "$failed"
}

# Names a file in the cache by its repo, since the file itself is named after
# its hash: /models/models--<user>--<repo>/… is <user>/<repo>.
cache_name() {
  local repo=${1#"$MODELS_DIR"/models--}

  repo=${repo%%/*}
  printf '%s\n' "${repo//--//}"
}

gigabytes() {
  local tenths=$(($1 / 100000000))

  printf '%d.%d GB\n' $((tenths / 10)) $((tenths % 10))
}

# llama.cpp shows no progress without a terminal, so this reports every file
# still downloading: its size so far, and its rate since the last report.
report_progress() {
  local -A last_size=() size=()
  local file bytes rate

  while sleep "$PROGRESS_INTERVAL"; do
    size=()
    while IFS= read -r -d '' file; do
      # The download may have finished since find listed it.
      bytes=$(stat --format=%s "$file" 2> /dev/null) || continue
      size[$file]=$bytes
      rate=""
      if [[ -n ${last_size[$file]:-} ]]; then
        rate=", $(((bytes - last_size[$file]) / PROGRESS_INTERVAL / 1000000)) MB/s"
      fi
      log "  $(cache_name "$file"): $(gigabytes "$bytes")$rate"
    done < <(find "$MODELS_DIR" -name '*.downloadInProgress' -print0)

    # Remember only the files still downloading, so one that starts over
    # under the same name isn't compared with its old size.
    last_size=()
    for file in "${!size[@]}"; do
      last_size[$file]=${size[$file]}
    done
  done
}

main() {
  local -a configs
  local checksum downloaded_checksum=""

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
      if download_declared_models "${configs[@]}"; then
        downloaded_checksum=$checksum
        log "All models present: $(du --summarize --human-readable "$MODELS_DIR" | cut --fields=1) on $MODELS_DIR"
      else
        log "Retrying the failed downloads in ${CHECK_INTERVAL}s"
      fi
    fi

    # Waiting on a background sleep lets SIGTERM stop the pod straight away.
    sleep "$CHECK_INTERVAL" &
    wait $!
  done
}

main
