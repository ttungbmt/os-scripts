ANTIDOTE_GITHUB_REPO="mattmc3/antidote"

antidote_fetch_local_version() {
  local target="/usr/local/share/antidote/.bumpversion.cfg"
  if [ -f "$target" ]; then
    grep "current_version =" "$target" | awk -F'=' '{print $2}' | tr -d ' \r\n'
  else
    echo ""
  fi
}
