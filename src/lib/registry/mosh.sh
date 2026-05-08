mosh_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | head -n 1 | awk '{print $NF}'
}

mosh_fetch_remote_version() {
  if command -v mosh >/dev/null 2>&1; then
    mosh --version 2>/dev/null | head -n 1 | awk '{print $NF}'
  fi
}
