RIPGREP_GITHUB_REPO="BurntSushi/ripgrep"
RIPGREP_INSTALL_TARGET="/usr/local/bin/rg"

ripgrep_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | head -1 | awk '{print $2}'
}
