KUBENT_INSTALL_TYPE="github_release"
KUBENT_GITHUB_REPO="doitintl/kube-no-trouble"
KUBENT_ARCHIVE_TYPE="tar.gz"
KUBENT_ASSET_PATTERN="kubent-${VERSION}-${DETECT_OS}-${DETECT_ARCH}.tar.gz"

kubent_fetch_local_version() {
  local target="$1"
  "$target" version --client --short 2>/dev/null | awk '{print $2}' || "$target" --version 2>/dev/null | awk '{print $3}'
}
