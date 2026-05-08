CLAUDE_INSTALL_TYPE="mise"
CLAUDE_MISE_PKG="npm:@anthropic-ai/claude-code"

claude_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | awk '{print $1}'
}

claude_fetch_remote_version() {
  mise latest npm:@anthropic-ai/claude-code 2>/dev/null
}
