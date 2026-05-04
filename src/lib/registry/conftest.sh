CONFTEST_INSTALL_TYPE="github_release"
CONFTEST_GITHUB_REPO="open-policy-agent/conftest"
CONFTEST_ARCHIVE_TYPE="tar.gz"
CONFTEST_ASSET_PATTERN="conftest_${VERSION}_${DETECT_OS}_x86_64.tar.gz"
CONFTEST_ARCH_MAP_amd64="x86_64"

conftest_fetch_local_version() {
  local target="$1"
  "$target" version --client --short 2>/dev/null | awk '{print $2}' || "$target" --version 2>/dev/null | awk '{print $3}'
}
