KYVERNO_INSTALL_TYPE="github_release"
KYVERNO_GITHUB_REPO="kyverno/kyverno"
KYVERNO_ARCHIVE_TYPE="tar.gz"
KYVERNO_ASSET_PATTERN="kyverno-cli_v${VERSION}_${DETECT_OS}_x86_64.tar.gz"
KYVERNO_BIN_PATH="kyverno"
KYVERNO_ARCH_MAP_amd64="x86_64"

kyverno_fetch_local_version() {
  local target="$1"
  "$target" version --client --short 2>/dev/null | awk '{print $2}' || "$target" --version 2>/dev/null | awk '{print $3}'
}
