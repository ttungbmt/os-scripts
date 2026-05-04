version=${args[--version]}
force=${args[--force]}
name="zoxide"
target="/usr/local/bin/zoxide"

# --- Step 1: Guard against overwrite ---
guard_existing "$name" "$target" "$force"

echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

# --- Step 2: Resolve version ---
if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "ajeetdsouza/zoxide")
fi

# Strip 'v' prefix if it exists
if [[ "$version" == v* ]]; then
  version="${version:1}"
fi

# --- Step 3: Detect platform ---
detect_platform

# Map OS and Architecture
os="unknown-linux-musl"
if [[ "$DETECT_OS" == "darwin" ]]; then
  os="apple-darwin"
fi

arch="x86_64"
if [[ "$DETECT_ARCH" == "arm64" ]]; then
  arch="aarch64"
fi

# --- Step 4: Build download URL ---
download_url="https://github.com/ajeetdsouza/zoxide/releases/download/v${version}/zoxide-${version}-${arch}-${os}.tar.gz"

# --- Step 5: Download & extract ---
temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/zoxide.tar.gz"
tar -xzf "$temp_dir/zoxide.tar.gz" -C "$temp_dir" zoxide

# --- Step 6: Install binary ---
if [ -f "$temp_dir/zoxide" ]; then
  install_binary "$temp_dir/zoxide" "$target"
  rm -rf "$temp_dir"
  echo "$(green_bold ✓) $name installed successfully: $(bold "v${version}")"
else
  echo "$(red ✗ Failed to install $name.)"
  rm -rf "$temp_dir"
  exit 1
fi
