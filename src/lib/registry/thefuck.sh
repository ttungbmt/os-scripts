THEFUCK_INSTALL_TYPE="pip"
THEFUCK_PIP_PKG="thefuck"

thefuck_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | awk '{print $2}'
}

thefuck_fetch_remote_version() {
  curl -s "https://pypi.org/pypi/thefuck/json" | sed -n 's/.*"version":"\([^"]*\)".*/\1/p' | head -n 1
}
