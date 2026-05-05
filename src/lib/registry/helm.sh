HELM_GITHUB_REPO="helm/helm"

helm_fetch_local_version() {
  local target="$1"
  "$target" version --short 2>/dev/null | awk -F+ '{print $1}'
}
