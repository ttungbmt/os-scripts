version=${args[--version]}
force=${args[--force]}
name="mcfly"
target="/usr/local/bin/mcfly"

# --- Step 1: Guard against overwrite ---
guard_existing "$name" "$target" "$force"

echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

# --- Step 2: Resolve version ---
if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "cantino/mcfly")
fi

# Strip 'v' prefix for URL construction
if [[ "$version" == v* ]]; then
  version="${version:1}"
fi

# --- Step 3: Detect platform ---
detect_platform

# mcfly uses x86_64/aarch64 arch naming
arch="x86_64"
if [[ "$DETECT_ARCH" == "arm64" ]]; then
  arch="aarch64"
fi

# --- Step 4: Build download URL ---
# Archive: mcfly-v{ver}-x86_64-unknown-linux-musl.tar.gz
# Binary inside: bare mcfly
download_url="https://github.com/cantino/mcfly/releases/download/v${version}/mcfly-v${version}-${arch}-unknown-linux-musl.tar.gz"

# --- Step 5: Download & extract ---
temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/mcfly.tar.gz"
tar -xzf "$temp_dir/mcfly.tar.gz" -C "$temp_dir" mcfly

# --- Step 6: Install binary ---
if [ -f "$temp_dir/mcfly" ]; then
  install_binary "$temp_dir/mcfly" "$target"
  rm -rf "$temp_dir"
  echo "$(green_bold ✓) $name installed successfully: $(bold "v${version}")"
else
  echo "$(red ✗ Failed to install $name.)"
  rm -rf "$temp_dir"
  exit 1
fi
