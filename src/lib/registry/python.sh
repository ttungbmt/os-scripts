PYTHON_INSTALL_TYPE="mise"
PYTHON_MISE_PKG="python"

python_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | awk '{print $2}'
}

python_fetch_remote_version() {
  mise latest python 2>/dev/null
}
