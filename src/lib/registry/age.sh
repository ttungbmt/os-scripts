AGE_INSTALL_TYPE="github_release"
AGE_GITHUB_REPO="FiloSottile/age"
AGE_ARCHIVE_TYPE="tar.gz"
AGE_ASSET_PATTERN="age-v${VERSION}-${DETECT_OS}-${DETECT_ARCH}.tar.gz"
AGE_BIN_PATH="age/age"

age_fetch_local_version() {
  local target="$1"
  "$target" version --client --short 2>/dev/null | awk '{print $2}' || "$target" --version 2>/dev/null | awk '{print $3}'
}
