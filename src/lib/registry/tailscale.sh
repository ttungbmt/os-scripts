TAILSCALE_GITHUB_REPO="tailscale/tailscale"

tailscale_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | awk 'NR==1 {print $1}'
}
