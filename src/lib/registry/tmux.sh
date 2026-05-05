tmux_fetch_local_version() {
  local target="$1"
  "$target" -V 2>/dev/null | awk '{print $2}'
}

tmux_fetch_remote_version() {
  if command -v tmux >/dev/null 2>&1; then
    tmux -V 2>/dev/null | awk '{print $2}'
  fi
}
