ZOXIDE_GITHUB_REPO="ajeetdsouza/zoxide"

zoxide_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | awk '{print $2}'
}
