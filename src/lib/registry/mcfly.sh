MCFLY_GITHUB_REPO="cantino/mcfly"

mcfly_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | awk '{print $2}'
}
