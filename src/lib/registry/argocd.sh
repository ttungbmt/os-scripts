ARGOCD_INSTALL_TYPE="github_release"
ARGOCD_GITHUB_REPO="argoproj/argo-cd"
ARGOCD_ARCHIVE_TYPE="binary"
ARGOCD_ASSET_PATTERN="argocd-${DETECT_OS}-${DETECT_ARCH}"

argocd_fetch_local_version() {
  local target="$1"
  "$target" version --client --short 2>/dev/null | awk '{print $2}' || "$target" --version 2>/dev/null | awk '{print $3}'
}
