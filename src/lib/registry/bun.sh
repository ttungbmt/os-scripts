BUN_INSTALL_TYPE="mise"
BUN_MISE_PKG="bun"

bun_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | sed 's/^v//'
}

bun_fetch_remote_version() {
  mise latest bun 2>/dev/null
}
