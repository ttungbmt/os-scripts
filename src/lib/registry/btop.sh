BTOP_GITHUB_REPO="aristocratos/btop"
BTOP_ARCHIVE_TYPE="tar.gz"
BTOP_ASSET_PATTERN="btop-\${DETECT_ARCH}-unknown-\${DETECT_OS}-musl.tar.gz"
BTOP_ARCH_MAP_amd64="x86_64"
BTOP_ARCH_MAP_arm64="aarch64"
BTOP_OS_MAP_linux="linux"
BTOP_BIN_PATH="btop/bin/btop"

btop_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | head -n 1 | awk '{print $3}' | cut -d'+' -f1 | sed 's/\x1b\[[0-9;]*m//g' | tr -d ' \r\n'
}
