KUBECTL_GITHUB_REPO="kubernetes/kubernetes"
KUBECTL_ARCHIVE_TYPE="binary"
KUBECTL_DOWNLOAD_URL="https://dl.k8s.io/release/\${V_VERSION}/bin/\${DETECT_OS}/\${DETECT_ARCH}/kubectl"

kubectl_fetch_local_version() {
  local target="$1"
  "$target" version --client -o yaml 2>/dev/null | grep gitVersion | awk '{print $2}'
}

kubectl_fetch_remote_version() {
  curl -sL https://dl.k8s.io/release/stable.txt
}
