gem_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null
}

gem_fetch_remote_version() {
  # Package manager tools: return local version so they appear up-to-date
  if command -v gem >/dev/null 2>&1; then
    gem --version 2>/dev/null
  fi
}
