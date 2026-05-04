KUSTOMIZE_GITHUB_REPO="kubernetes-sigs/kustomize"
KUSTOMIZE_ARCHIVE_TYPE="tar.gz"
KUSTOMIZE_ASSET_PATTERN="kustomize_\${V_VERSION}_\${DETECT_OS}_\${DETECT_ARCH}.tar.gz"
KUSTOMIZE_TAG_PREFIX="kustomize/v"

kustomize_fetch_local_version() {
  local target="$1"
  local ver=$("$target" version --short 2>/dev/null || "$target" version)
  echo "$ver" | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -n 1
}

kustomize_fetch_remote_version() {
  curl -s "https://api.github.com/repos/${KUSTOMIZE_GITHUB_REPO}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"kustomize\/v?([^"]+)".*/\1/'
}
