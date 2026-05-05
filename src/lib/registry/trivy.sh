TRIVY_INSTALL_TYPE="github_release"
TRIVY_GITHUB_REPO="aquasecurity/trivy"
TRIVY_ARCHIVE_TYPE="tar.gz"
TRIVY_ASSET_PATTERN="trivy_\${VERSION}_\${DETECT_OS}-\${DETECT_ARCH}.tar.gz"
TRIVY_OS_MAP_linux="Linux"
TRIVY_OS_MAP_darwin="macOS"
TRIVY_ARCH_MAP_amd64="64bit"
TRIVY_ARCH_MAP_arm64="ARM64"

trivy_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | head -n1 | awk '{print $2}'
}
