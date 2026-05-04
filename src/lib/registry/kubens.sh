KUBENS_INSTALL_TYPE="github_release"
KUBENS_GITHUB_REPO="ahmetb/kubectx"
KUBENS_ARCHIVE_TYPE="tar.gz"
KUBENS_ASSET_PATTERN="kubens_v${VERSION}_${DETECT_OS}_x86_64.tar.gz"
KUBENS_ARCH_MAP_amd64="x86_64"

kubens_fetch_local_version() {
  local target="$1"
  "$target" version --client --short 2>/dev/null | awk '{print $2}' || "$target" --version 2>/dev/null | awk '{print $3}'
}
