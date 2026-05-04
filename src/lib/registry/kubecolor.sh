KUBECOLOR_INSTALL_TYPE="github_release"
KUBECOLOR_GITHUB_REPO="kubecolor/kubecolor"
KUBECOLOR_ARCHIVE_TYPE="tar.gz"
KUBECOLOR_ASSET_PATTERN="kubecolor_${VERSION}_${DETECT_OS}_${DETECT_ARCH}.tar.gz"

kubecolor_fetch_local_version() {
  local target="$1"
  "$target" version --client --short 2>/dev/null | awk '{print $2}' || "$target" --version 2>/dev/null | awk '{print $3}'
}
