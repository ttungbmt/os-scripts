FASTFETCH_GITHUB_REPO="fastfetch-cli/fastfetch"
FASTFETCH_ARCHIVE_TYPE="tar.gz"
FASTFETCH_ASSET_PATTERN="fastfetch-\${DETECT_OS}-\${DETECT_ARCH}.tar.gz"
FASTFETCH_ARCH_MAP_arm64="aarch64"
FASTFETCH_OS_MAP_darwin="macos"
FASTFETCH_TAG_PREFIX=""

fastfetch_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | awk '{print $2}'
}
