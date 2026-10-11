#!/usr/bin/env bash
# Downloads every model llama-swap's config names, and any it gains later. It
# runs beside llama-swap rather than before it, so llama-swap serves the models
# already on /models while new ones download.
#
# The config names a model in one of two ways:
#
#   -hf <user>/<repo>:<quant>
#       llama.cpp's own downloader fetches the repo's GGUF for that quant into
#       its Hugging Face cache. It skips files it already has, and resumes one
#       it was interrupted in.
#
#   --<flag> /models/hf/<user>/<repo>/<path>
#       Any other file under /models/hf/ mirrors its location on Hugging Face.
#       curl fetches it once.

set -uo pipefail
shopt -s nullglob

readonly MODELS_DIR=/models
readonly HF_FILES_DIR=/models/hf
readonly CHECK_INTERVAL=60    # seconds between checks of the config
readonly PROGRESS_INTERVAL=30 # seconds between progress reports

# Only gated repos need a token. llama.cpp reads HF_TOKEN itself.
HF_AUTH=()
if [[ -n ${HF_TOKEN:-} ]]; then
  HF_AUTH=(--header "Authorization: Bearer $HF_TOKEN")
fi
readonly HF_AUTH

log() {
  printf '%s\n' "$*"
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

download_hf_model() {
  local model=$1

  log "Checking $model"
  /app/llama download -hf "$model"
}

download_hf_file() {
  local path=$1
  local user repo file_in_repo

  [[ -f $path ]] && return 0

  IFS=/ read -r user repo file_in_repo <<< "${path#"$HF_FILES_DIR"/}"
  log "Downloading $user/$repo/$file_in_repo"
  mkdir --parents "$(dirname "$path")"

  # A partial download keeps the .part suffix, so it never looks complete, and
  # the next attempt resumes it.
  curl --fail --silent --show-error --location --retry 3 --continue-at - \
    "${HF_AUTH[@]}" --output "$path.part" \
    "https://huggingface.co/$user/$repo/resolve/main/$file_in_repo" &&
    mv "$path.part" "$path"
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

# The name a progress report gives a file that's still downloading.
download_name() {
  local file=$1
  local cache_dir

  case $file in
    "$MODELS_DIR"/models--*)
      # llama.cpp names the file after its hash, so use its cache directory
      # instead: models--<user>--<repo> is <user>/<repo>.
      cache_dir=${file#"$MODELS_DIR"/models--}
      cache_dir=${cache_dir%%/*}
      printf '%s\n' "${cache_dir//--//}"
      ;;
    *)
      file=${file#"$HF_FILES_DIR"/}
      printf '%s\n' "${file%.part}"
      ;;
  esac
}

gigabytes() {
  local tenths=$(($1 / 100000000))

  printf '%d.%d GB\n' $((tenths / 10)) $((tenths % 10))
}

# Neither downloader shows progress without a terminal, so this reports every
# file still downloading: its size so far, and its rate since the last report.
report_progress() {
  local -A last_size=()
  local file size rate

  while sleep "$PROGRESS_INTERVAL"; do
    while IFS= read -r -d '' file; do
      # The download may have finished since find listed it.
      size=$(stat --format=%s "$file" 2> /dev/null) || continue
      rate=""
      if [[ -n ${last_size[$file]:-} ]]; then
        rate=", $(((size - last_size[$file]) / PROGRESS_INTERVAL / 1000000)) MB/s"
      fi
      last_size[$file]=$size
      log "  $(download_name "$file"): $(gigabytes "$size")$rate"
    done < <(find "$MODELS_DIR" \( -name '*.downloadInProgress' -o -name '*.part' \) -print0)
  done
}

main() {
  local -a configs
  local checksum downloaded_checksum=""

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
