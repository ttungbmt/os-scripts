rsync_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | head -n 1 | awk '{print $3}'
}

rsync_fetch_remote_version() {
  if command -v rsync >/dev/null 2>&1; then
    rsync --version 2>/dev/null | head -n 1 | awk '{print $3}'
  fi
}
