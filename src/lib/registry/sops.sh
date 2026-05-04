SOPS_INSTALL_TYPE="github_release"
SOPS_GITHUB_REPO="getsops/sops"
SOPS_ARCHIVE_TYPE="binary"
SOPS_ASSET_PATTERN="sops-v${VERSION}.${DETECT_OS}.${DETECT_ARCH}"

sops_fetch_local_version() {
  local target="$1"
  "$target" version --client --short 2>/dev/null | awk '{print $2}' || "$target" --version 2>/dev/null | awk '{print $3}'
}
