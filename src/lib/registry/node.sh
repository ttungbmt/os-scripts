NODE_INSTALL_TYPE="mise"
NODE_MISE_PKG="node"

node_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | sed 's/^v//'
}

node_fetch_remote_version() {
  mise latest node 2>/dev/null
}
