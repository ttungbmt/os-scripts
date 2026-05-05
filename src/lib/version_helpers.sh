## Version helpers for CLI tools
## This file is located in 'src/lib/version_helpers.sh'

# Default local version probe for tools that don't define their own fetch_local_version.
# Tries `version --client --short` then falls back to `--version`.
_default_fetch_local_version() {
  local target="$1"
  "$target" version --client --short 2>/dev/null | awk '{print $2}' \
    || "$target" --version 2>/dev/null | awk '{print $3}'
}

# Get the local version of a tool (without 'v' prefix)
# Usage: get_local_version "tool_name"
# Returns: version string (e.g., "0.50.18") or empty if not installed/error
get_local_version() {
  local tool="$1"
  local fn_name
  fn_name="$(echo "$tool" | tr '-' '_')_fetch_local_version"
  local target="/usr/local/bin/$tool"

  if [ ! -f "$target" ]; then
    target=$(command -v "$tool" 2>/dev/null)
  fi

  if [ -z "$target" ] || [ ! -f "$target" ]; then
    echo ""
    return
  fi

  local ver=""
  if type "$fn_name" >/dev/null 2>&1; then
    ver=$("$fn_name" "$target")
  else
    ver=$(_default_fetch_local_version "$target")
  fi

  # Strip leading v
  if [[ "$ver" == v* ]]; then
    ver="${ver:1}"
  fi

  echo "$ver"
}

# Get the remote version of a tool (without 'v' prefix)
# Usage: get_remote_version "tool_name"
# Returns: version string (e.g., "0.50.18") or empty if error
get_remote_version() {
  local tool="$1"
  local tool_upper
  tool_upper=$(echo "$tool" | tr '[:lower:]' '[:upper:]' | tr '-' '_')

  local fn_name
  fn_name="$(echo "$tool" | tr '-' '_')_fetch_remote_version"
  local repo_var="${tool_upper}_GITHUB_REPO"

  local ver=""

  if type "$fn_name" >/dev/null 2>&1; then
    ver=$("$fn_name")
  else
    # Use indirect reference to get the repo value
    local repo_val="${!repo_var}"
    if [ -n "$repo_val" ]; then
      local api_opts=(-s "https://api.github.com/repos/${repo_val}/releases/latest")
      if [[ -n "$GITHUB_TOKEN" ]]; then
        api_opts=(-s -H "Authorization: Bearer $GITHUB_TOKEN" "https://api.github.com/repos/${repo_val}/releases/latest")
      fi
      ver=$(curl "${api_opts[@]}" | grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/')
    fi
  fi

  # Strip leading v just in case
  if [[ "$ver" == v* ]]; then
    ver="${ver:1}"
  fi

  echo "$ver"
}
