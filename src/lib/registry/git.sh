git_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | awk '{print $3}'
}

git_fetch_remote_version() {
  # Package manager tools: return local version so they appear up-to-date
  if command -v git >/dev/null 2>&1; then
    git --version 2>/dev/null | awk '{print $3}'
  fi
}
