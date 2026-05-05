HYPERFINE_GITHUB_REPO="sharkdp/hyperfine"

hyperfine_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | awk '{print $2}'
}
