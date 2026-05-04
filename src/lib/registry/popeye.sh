POPEYE_INSTALL_TYPE="github_release"
POPEYE_GITHUB_REPO="derailed/popeye"
POPEYE_ARCHIVE_TYPE="tar.gz"
POPEYE_ASSET_PATTERN="popeye_${DETECT_OS}_${DETECT_ARCH}.tar.gz"

popeye_fetch_local_version() {
  local target="$1"
  "$target" version --client --short 2>/dev/null | awk '{print $2}' || "$target" --version 2>/dev/null | awk '{print $3}'
}
