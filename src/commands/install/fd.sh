version=${args[--version]}
force=${args[--force]}
name="fd"
target="/usr/local/bin/fd"

# --- Step 1: Guard against overwrite ---
guard_existing "$name" "$target" "$force"

echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

# --- Step 2: Resolve version ---
if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "sharkdp/fd")
fi

# Strip 'v' prefix for URL construction
if [[ "$version" == v* ]]; then
  version="${version:1}"
fi

# --- Step 3: Detect platform ---
detect_platform

# fd uses x86_64/aarch64 arch naming
arch="x86_64"
if [[ "$DETECT_ARCH" == "arm64" ]]; then
  arch="aarch64"
fi

# --- Step 4: Build download URL ---
# Archive: fd-v{ver}-x86_64-unknown-linux-musl.tar.gz
# Binary inside: fd-v{ver}-x86_64-unknown-linux-musl/fd
download_url="https://github.com/sharkdp/fd/releases/download/v${version}/fd-v${version}-${arch}-unknown-linux-musl.tar.gz"
binary_path="fd-v${version}-${arch}-unknown-linux-musl/fd"

# --- Step 5: Download & extract ---
temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/fd.tar.gz"
tar -xzf "$temp_dir/fd.tar.gz" -C "$temp_dir" "$binary_path"

# --- Step 6: Install binary ---
if [ -f "$temp_dir/$binary_path" ]; then
  install_binary "$temp_dir/$binary_path" "$target"
  rm -rf "$temp_dir"
  echo "$(green_bold ✓) $name installed successfully: $(bold "v${version}")"
else
  echo "$(red ✗ Failed to install $name.)"
  rm -rf "$temp_dir"
  exit 1
fi
