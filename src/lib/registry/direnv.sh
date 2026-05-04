DIRENV_GITHUB_REPO="direnv/direnv"
DIRENV_ARCHIVE_TYPE="binary"
DIRENV_ASSET_PATTERN="direnv.\${DETECT_OS}-\${DETECT_ARCH}"

direnv_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null
}
