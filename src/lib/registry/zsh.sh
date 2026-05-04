zsh_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | awk '{print $2}' | tr -d ' \r\n'
}

zsh_fetch_remote_version() {
  # Since zsh is managed by OS package manager, we return the local version 
  # so it always appears up-to-date, as remote versions depend on the distro package cache.
  if command -v zsh >/dev/null 2>&1; then
    zsh --version 2>/dev/null | awk '{print $2}' | tr -d ' \r\n'
  else
    echo ""
  fi
}
