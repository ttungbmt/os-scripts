version=${args[--version]}
force=${args[--force]}
name="bat"
target="/usr/local/bin/bat"

# --- Step 1: Guard against overwrite ---
guard_existing "$name" "$target" "$force"

echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

# --- Step 2: Resolve version ---
if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "sharkdp/bat")
fi

# Strip 'v' prefix for URL construction
if [[ "$version" == v* ]]; then
  version="${version:1}"
fi

# --- Step 3: Detect platform ---
detect_platform

# Map architecture
arch="x86_64"
if [[ "$DETECT_ARCH" == "arm64" ]]; then
  arch="aarch64"
fi

# Map OS
os="unknown-linux-musl"
if [[ "$DETECT_OS" == "darwin" ]]; then
  os="apple-darwin"
fi

# --- Step 4: Build download URL ---
archive_name="bat-v${version}-${arch}-${os}"
download_url="https://github.com/sharkdp/bat/releases/download/v${version}/${archive_name}.tar.gz"

# --- Step 5: Download & extract ---
temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/bat.tar.gz"
tar -xzf "$temp_dir/bat.tar.gz" -C "$temp_dir"

# --- Step 6: Install binary ---
if [ -f "$temp_dir/${archive_name}/bat" ]; then
  install_binary "$temp_dir/${archive_name}/bat" "$target"
  rm -rf "$temp_dir"
  echo "$(green_bold ✓) $name installed successfully: $(bold "v${version}")"
else
  echo "$(red ✗ Failed to install $name.)"
  rm -rf "$temp_dir"
  exit 1
fi
