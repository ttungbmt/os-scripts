NERDCTL_GITHUB_REPO="containerd/nerdctl"

nerdctl_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | awk '{print $3}'
}
