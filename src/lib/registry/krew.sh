KREW_INSTALL_TYPE="github_release"
KREW_GITHUB_REPO="kubernetes-sigs/krew"
KREW_ARCHIVE_TYPE="tar.gz"
KREW_ASSET_PATTERN="krew-${DETECT_OS}_${DETECT_ARCH}.tar.gz"
KREW_BIN_PATH="krew-${DETECT_OS}_${DETECT_ARCH}"

krew_fetch_local_version() {
  local target="$1"
  "$target" version --client --short 2>/dev/null | awk '{print $2}' || "$target" --version 2>/dev/null | awk '{print $3}'
}
