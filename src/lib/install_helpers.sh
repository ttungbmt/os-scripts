## Shared install/uninstall helpers for CLI tools
## This file is located in 'src/lib/install_helpers.sh'

# Detect OS and ARCH, sets global vars: DETECT_OS, DETECT_ARCH
detect_platform() {
  local raw_os raw_arch
  raw_os="$(uname -s)"
  raw_arch="$(uname -m)"

  case "$raw_os" in
    Linux)  DETECT_OS="linux" ;;
    Darwin) DETECT_OS="darwin" ;;
    *)      echo "$(red Error:) Unsupported OS: $raw_os"; exit 1 ;;
  esac

  case "$raw_arch" in
    x86_64)  DETECT_ARCH="amd64" ;;
    aarch64) DETECT_ARCH="arm64" ;;
    arm64)   DETECT_ARCH="arm64" ;;
    *)       echo "$(red Error:) Unsupported architecture: $raw_arch"; exit 1 ;;
  esac
}

# Fetch the latest release tag from a GitHub repo
# Usage: github_latest_tag "owner/repo"
# Returns: tag string (e.g. "v0.50.18")
github_latest_tag() {
  local repo="$1"
  local tag
  tag=$(curl -s "https://api.github.com/repos/${repo}/releases/latest" \
    | grep '"tag_name":' \
    | sed -E 's/.*"([^"]+)".*/\1/')
  if [ -z "$tag" ]; then
    echo "$(red Error:) Could not fetch latest version for ${repo}."
    exit 1
  fi
  echo "$tag"
}

# Guard: check if a binary already exists, exit unless --force is set
# Usage: guard_existing "tool_name" "/path/to/binary" "$force_flag"
guard_existing() {
  local name="$1" target="$2" force="$3"
  if [ -f "$target" ] && [ -z "$force" ]; then
    echo "$(red Error:) ${name} is already installed at ${target}."
    echo "Use $(bold --force) (or $(bold -f)) to overwrite."
    exit 1
  fi
}

# Move a file to /usr/local/bin, using sudo if necessary
# Usage: install_binary "/tmp/downloaded_binary" "/usr/local/bin/tool"
install_binary() {
  local src="$1" dest="$2"
  chmod +x "$src"
  if [ -w "$(dirname "$dest")" ]; then
    mv -f "$src" "$dest"
  else
    sudo mv -f "$src" "$dest"
  fi
}

# Remove a binary from a path, using sudo if necessary
# Usage: remove_binary "/usr/local/bin/tool"
remove_binary() {
  local target="$1"
  if [ -w "$(dirname "$target")" ]; then
    rm -f "$target"
  else
    sudo rm -f "$target"
  fi
}

# Download a file with a progress bar
# Usage: download_file "https://example.com/file.tar.gz" "/tmp/output.tar.gz"
download_file() {
  local url="$1" dest="$2"
  curl -#fL "$url" -o "$dest"
  if [ $? -ne 0 ] || [ ! -f "$dest" ]; then
    echo "$(red Error:) Failed to download from ${url}"
    rm -rf "$(dirname "$dest")"
    exit 1
  fi
}

# Standard uninstall flow for a single binary
# Usage: uninstall_tool "tool_name" "/usr/local/bin/tool"
uninstall_tool() {
  local name="$1" target="$2"

  if [ ! -f "$target" ]; then
    echo "$(yellow ${name} is not installed) at ${target}."
    exit 0
  fi

  echo "Uninstalling $(cyan_bold "${name}")..."
  remove_binary "$target"

  if [ ! -f "$target" ]; then
    echo "$(green_bold ✓) ${name} uninstalled successfully."
  else
    echo "$(red ✗ Failed to uninstall ${name}.)"
    exit 1
  fi
}
