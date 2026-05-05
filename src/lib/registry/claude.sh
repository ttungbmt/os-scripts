CLAUDE_INSTALL_TYPE="npm"
CLAUDE_NPM_PKG="@anthropic-ai/claude-code"

claude_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | awk '{print $1}'
}

claude_fetch_remote_version() {
  npm view @anthropic-ai/claude-code version 2>/dev/null
}
