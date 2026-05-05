UV_GITHUB_REPO="astral-sh/uv"
UV_ARCHIVE_TYPE="tar.gz"
UV_ASSET_PATTERN="uv-\${DETECT_ARCH}-unknown-\${DETECT_OS}-gnu.tar.gz"
UV_ARCH_MAP_amd64="x86_64"
UV_ARCH_MAP_arm64="aarch64"
UV_BIN_PATH="uv-\${DETECT_ARCH}-unknown-\${DETECT_OS}-gnu/uv"

uv_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | awk '{print $2}'
}
