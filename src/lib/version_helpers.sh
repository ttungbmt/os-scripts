## Version helpers for CLI tools
## This file is located in 'src/lib/version_helpers.sh'

# Get the local version of a tool (without 'v' prefix)
# Usage: get_local_version "tool_name"
# Returns: version string (e.g., "0.50.18") or empty if not installed/error
get_local_version() {
  local tool="$1"
  # Replace hyphens with underscores for function names if needed, but our tools don't have hyphens yet
  local fn_name="${tool}_fetch_local_version"
  local target="/usr/local/bin/$tool"
  
  if [ ! -f "$target" ]; then
    target=$(command -v "$tool" 2>/dev/null)
  fi

  local ver=""
  if type "$fn_name" >/dev/null 2>&1; then
    ver=$("$fn_name" "$target")
  else
    if [ -z "$target" ] || [ ! -f "$target" ]; then
      echo ""
      return
    fi
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
  # uppercase tool name for variable
  local tool_upper
  tool_upper=$(echo "$tool" | tr '[:lower:]' '[:upper:]')
  
  local fn_name="${tool}_fetch_remote_version"
  local repo_var="${tool_upper}_GITHUB_REPO"
  
  local ver=""
  
  if type "$fn_name" >/dev/null 2>&1; then
    ver=$("$fn_name")
  else
    # Use indirect reference to get the repo value
    local repo_val="${!repo_var}"
    if [ -n "$repo_val" ]; then
      ver=$(curl -s "https://api.github.com/repos/${repo_val}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/')
    fi
  fi

  # Strip leading v just in case
  if [[ "$ver" == v* ]]; then
    ver="${ver:1}"
  fi
  
  echo "$ver"
}
