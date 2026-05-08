BATS_GITHUB_REPO="bats-core/bats-core"

bats_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | awk '{print $2}'
}
