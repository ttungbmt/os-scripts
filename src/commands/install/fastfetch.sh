version=${args[--version]}
force=${args[--force]}
name="fastfetch"
target="/usr/local/bin/fastfetch"

# --- Step 1: Guard against overwrite ---
guard_existing "$name" "$target" "$force"

echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

# --- Step 2: Resolve version ---
if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "fastfetch-cli/fastfetch")
fi

# Strip 'v' prefix
if [[ "$version" == v* ]]; then
  version="${version:1}"
fi

# --- Step 3: Detect platform ---
detect_platform

# --- Step 4: Build download URL ---
download_url="https://github.com/fastfetch-cli/fastfetch/releases/download/${version}/fastfetch-${DETECT_OS}-${DETECT_ARCH}.tar.gz"

# --- Step 5: Download & extract ---
temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/$name.tar.gz"

# fastfetch tar.gz contains a nested folder (e.g., fastfetch-linux-amd64/usr/bin/fastfetch)
# We can use tar with --strip-components to extract just the binary, or extract all and find it.
# Let's extract everything and find the binary
tar -xzf "$temp_dir/$name.tar.gz" -C "$temp_dir"

# Find the binary
extracted_binary=$(find "$temp_dir" -type f -name "fastfetch" -executable | head -n 1)

# --- Step 6: Install binary ---
if [ -n "$extracted_binary" ] && [ -f "$extracted_binary" ]; then
  install_binary "$extracted_binary" "$target"
  rm -rf "$temp_dir"
  echo "$(green_bold ✓) $name installed successfully: $(bold "$version")"
else
  echo "$(red ✗ Failed to install $name.) Could not extract binary."
  rm -rf "$temp_dir"
  exit 1
fi
