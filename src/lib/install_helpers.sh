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

# Require: check if a tool is installed, exit if it is not
# Usage: require_installed "tool_name" "/path/to/binary_or_dir"
require_installed() {
  local name="$1" target="$2"
  if [ ! -e "$target" ] && ! command -v "$name" >/dev/null 2>&1; then
    echo "$(red "✗") ${name} is not installed."
    echo "Please run $(bold "./gt install ${name}") first."
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

  echo -n "Are you sure you want to uninstall $(cyan_bold "${name}") at $target? [y/N] "
  read -r response
  if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Aborted."
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

# Install a package using the system package manager
# Usage: install_package "pkg_name"
install_package() {
  local pkg="$1"
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -yqq
    sudo apt-get install -y "$pkg"
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y "$pkg"
  elif command -v yum >/dev/null 2>&1; then
    sudo yum install -y "$pkg"
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --noconfirm "$pkg"
  elif command -v apk >/dev/null 2>&1; then
    sudo apk add "$pkg"
  else
    echo "$(red ✗) Could not detect a supported package manager (apt/dnf/yum/pacman/apk)."
    return 1
  fi
}

# Remove a package using the system package manager
# Usage: remove_package "pkg_name"
remove_package() {
  local pkg="$1"
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get remove -y "$pkg"
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf remove -y "$pkg"
  elif command -v yum >/dev/null 2>&1; then
    sudo yum remove -y "$pkg"
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Rs --noconfirm "$pkg"
  elif command -v apk >/dev/null 2>&1; then
    sudo apk del "$pkg"
  else
    echo "$(red ✗) Could not detect a supported package manager."
    return 1
  fi
}

# Install a tool by cloning a git repository
# Usage: install_git_repo "https://github.com/user/repo.git" "/dest/path" "branch_or_tag"
install_git_repo() {
  local repo_url="$1" dest="$2" version="$3"
  
  if [ -d "$dest" ]; then
    echo "Directory $dest already exists. Pulling latest changes..."
    if [ ! -w "$dest" ]; then
      sudo git -C "$dest" fetch --tags
      if [ -n "$version" ] && [ "$version" != "latest" ]; then
        sudo git -C "$dest" checkout "$version"
      else
        sudo git -C "$dest" pull
      fi
    else
      git -C "$dest" fetch --tags
      if [ -n "$version" ] && [ "$version" != "latest" ]; then
        git -C "$dest" checkout "$version"
      else
        git -C "$dest" pull
      fi
    fi
  else
    echo "Cloning $repo_url to $dest..."
    local parent_dir="$(dirname "$dest")"
    if [ ! -w "$parent_dir" ]; then
      sudo mkdir -p "$parent_dir"
      if [ -n "$version" ] && [ "$version" != "latest" ]; then
        sudo git clone --depth=1 --branch "$version" "$repo_url" "$dest"
      else
        sudo git clone --depth=1 "$repo_url" "$dest"
      fi
    else
      mkdir -p "$parent_dir"
      if [ -n "$version" ] && [ "$version" != "latest" ]; then
        git clone --depth=1 --branch "$version" "$repo_url" "$dest"
      else
        git clone --depth=1 "$repo_url" "$dest"
      fi
    fi
  fi
}

# Remove a git repository directory
# Usage: remove_git_repo "/dest/path"
remove_git_repo() {
  local dest="$1"
  if [ -d "$dest" ]; then
    if [ ! -w "$(dirname "$dest")" ]; then
      sudo rm -rf "$dest"
    else
      rm -rf "$dest"
    fi
  else
    echo "$(yellow Directory $dest does not exist.)"
  fi
}
