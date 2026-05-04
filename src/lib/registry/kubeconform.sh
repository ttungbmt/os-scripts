KUBECONFORM_INSTALL_TYPE="github_release"
KUBECONFORM_GITHUB_REPO="yannh/kubeconform"
KUBECONFORM_ARCHIVE_TYPE="tar.gz"
KUBECONFORM_ASSET_PATTERN="kubeconform-${DETECT_OS}-${DETECT_ARCH}.tar.gz"

kubeconform_fetch_local_version() {
  local target="$1"
  "$target" version --client --short 2>/dev/null | awk '{print $2}' || "$target" --version 2>/dev/null | awk '{print $3}'
}
