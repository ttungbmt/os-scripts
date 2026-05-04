FD_GITHUB_REPO="sharkdp/fd"

fd_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | awk '{print $2}'
}
