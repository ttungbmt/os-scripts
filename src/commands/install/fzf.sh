version=${args[--version]}
force=${args[--force]}
name="fzf"
target="/usr/local/bin/fzf"

# --- Step 1: Guard against overwrite ---
guard_existing "$name" "$target" "$force"

echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

# --- Step 2: Resolve version ---
if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "junegunn/fzf")
fi

# Strip 'v' prefix for URL construction
if [[ "$version" == v* ]]; then
  version="${version:1}"
fi

# --- Step 3: Detect platform ---
detect_platform

# fzf uses linux/darwin for OS and amd64/arm64 for arch
os="linux"
if [[ "$DETECT_OS" == "darwin" ]]; then
  os="darwin"
fi

arch="$DETECT_ARCH"

# --- Step 4: Build download URL ---
download_url="https://github.com/junegunn/fzf/releases/download/v${version}/fzf-${version}-${os}_${arch}.tar.gz"

# --- Step 5: Download & extract ---
temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/fzf.tar.gz"
tar -xzf "$temp_dir/fzf.tar.gz" -C "$temp_dir" fzf

# --- Step 6: Install binary ---
if [ -f "$temp_dir/fzf" ]; then
  install_binary "$temp_dir/fzf" "$target"
  rm -rf "$temp_dir"
  echo "$(green_bold ✓) $name installed successfully: $(bold "v${version}")"
else
  echo "$(red ✗ Failed to install $name.)"
  rm -rf "$temp_dir"
  exit 1
fi
