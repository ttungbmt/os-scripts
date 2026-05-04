KUBESEAL_INSTALL_TYPE="github_release"
KUBESEAL_GITHUB_REPO="bitnami-labs/sealed-secrets"
KUBESEAL_ARCHIVE_TYPE="tar.gz"
KUBESEAL_ASSET_PATTERN="kubeseal-${VERSION}-${DETECT_OS}-${DETECT_ARCH}.tar.gz"

kubeseal_fetch_local_version() {
  local target="$1"
  "$target" version --client --short 2>/dev/null | awk '{print $2}' || "$target" --version 2>/dev/null | awk '{print $3}'
}
