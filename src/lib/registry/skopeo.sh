skopeo_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | awk '{print $3}'
}

skopeo_fetch_remote_version() {
  if command -v skopeo >/dev/null 2>&1; then
    skopeo --version 2>/dev/null | awk '{print $3}'
  fi
}
