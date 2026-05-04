KUBE_LINTER_INSTALL_TYPE="github_release"
KUBE_LINTER_GITHUB_REPO="stackrox/kube-linter"
KUBE_LINTER_ARCHIVE_TYPE="tar.gz"
KUBE_LINTER_ASSET_PATTERN="kube-linter-${DETECT_OS}.tar.gz"

kube_linter_fetch_local_version() {
  local target="$1"
  "$target" version --client --short 2>/dev/null | awk '{print $2}' || "$target" --version 2>/dev/null | awk '{print $3}'
}
