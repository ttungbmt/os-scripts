JQ_GITHUB_REPO="jqlang/jq"

jq_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | awk '{print $1}'
}
