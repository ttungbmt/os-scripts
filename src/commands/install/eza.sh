version=${args[--version]}
force=${args[--force]}
name="eza"
target="/usr/local/bin/eza"

# --- Step 1: Guard against overwrite ---
guard_existing "$name" "$target" "$force"

echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

# --- Step 2: Resolve version ---
if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "eza-community/eza")
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

# --- Step 4: Build download URL ---
download_url="https://github.com/eza-community/eza/releases/download/v${version}/eza_${arch}-unknown-linux-gnu.tar.gz"

# --- Step 5: Download & extract ---
temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/eza.tar.gz"
tar -xzf "$temp_dir/eza.tar.gz" -C "$temp_dir" ./eza

# --- Step 6: Install binary ---
if [ -f "$temp_dir/eza" ]; then
  install_binary "$temp_dir/eza" "$target"
  rm -rf "$temp_dir"
  echo "$(green_bold ✓) $name installed successfully: $(bold "v${version}")"
else
  echo "$(red ✗ Failed to install $name.)"
  rm -rf "$temp_dir"
  exit 1
fi
