K9S_GITHUB_REPO="derailed/k9s"

k9s_fetch_local_version() {
  local target="$1"
  "$target" version -s 2>/dev/null | awk '/Version/ {print $2}'
}
