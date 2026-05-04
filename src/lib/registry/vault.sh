VAULT_INSTALL_TYPE="github_release"
VAULT_GITHUB_REPO="hashicorp/vault"
VAULT_ARCHIVE_TYPE="zip"
VAULT_ASSET_PATTERN="vault_${VERSION}_${DETECT_OS}_${DETECT_ARCH}.zip"
VAULT_DOWNLOAD_URL="https://releases.hashicorp.com/vault/${VERSION}/vault_${VERSION}_${DETECT_OS}_${DETECT_ARCH}.zip"

vault_fetch_local_version() {
  local target="$1"
  "$target" version --client --short 2>/dev/null | awk '{print $2}' || "$target" --version 2>/dev/null | awk '{print $3}'
}
