VELERO_INSTALL_TYPE="github_release"
VELERO_GITHUB_REPO="vmware-tanzu/velero"
VELERO_ARCHIVE_TYPE="tar.gz"
VELERO_ASSET_PATTERN="velero-v${VERSION}-${DETECT_OS}-${DETECT_ARCH}.tar.gz"
VELERO_BIN_PATH="velero-v${VERSION}-${DETECT_OS}-${DETECT_ARCH}/velero"

velero_fetch_local_version() {
  local target="$1"
  "$target" version --client --short 2>/dev/null | awk '{print $2}' || "$target" --version 2>/dev/null | awk '{print $3}'
}
