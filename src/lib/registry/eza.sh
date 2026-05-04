EZA_GITHUB_REPO="eza-community/eza"

eza_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | head -1 | awk '{print $2}'
}
