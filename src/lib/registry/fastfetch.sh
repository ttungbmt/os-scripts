FASTFETCH_GITHUB_REPO="fastfetch-cli/fastfetch"

fastfetch_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | awk '{print $2}'
}
