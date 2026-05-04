DIRENV_GITHUB_REPO="direnv/direnv"

direnv_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null
}
