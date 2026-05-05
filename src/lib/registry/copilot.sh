COPILOT_GITHUB_REPO="github/copilot-cli"

copilot_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | head -n 1 | awk '{print $4}' | sed 's/\.$//'
}
