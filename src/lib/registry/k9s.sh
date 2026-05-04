K9S_GITHUB_REPO="derailed/k9s"
K9S_ARCHIVE_TYPE="tar.gz"
K9S_ASSET_PATTERN="k9s_\${DETECT_OS}_\${DETECT_ARCH}.tar.gz"
K9S_OS_MAP_linux="Linux"
K9S_OS_MAP_darwin="Darwin"

k9s_fetch_local_version() {
  local target="$1"
  "$target" version -s 2>/dev/null | awk '/Version/ {print $2}'
}
