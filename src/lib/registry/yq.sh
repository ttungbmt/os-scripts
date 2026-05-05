YQ_GITHUB_REPO="mikefarah/yq"

yq_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | awk '{print $NF}'
}
