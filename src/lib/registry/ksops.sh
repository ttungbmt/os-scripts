KSOPS_GITHUB_REPO="viaduct-ai/kustomize-sops"

ksops_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | awk '{print $3}'
}
