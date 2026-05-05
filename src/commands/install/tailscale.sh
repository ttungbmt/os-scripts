version=${args[--version]}
force=${args[--force]}
name="tailscale"
target="/usr/local/bin/tailscale"

# --- Step 1: Guard against overwrite ---
guard_existing "$name" "$target" "$force"

echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

# --- Step 2: Resolve version ---
if [[ "$version" == "latest" ]]; then
  version=$(curl -s "https://pkgs.tailscale.com/stable/" | grep -o 'tailscale_[0-9.]*_amd64.tgz' | head -n 1 | cut -d'_' -f2)
fi

if [[ "$version" == v* ]]; then
  version="${version:1}"
fi

# --- Step 3: Detect platform ---
detect_platform

# --- Step 4: Build download URL ---
download_url="https://pkgs.tailscale.com/stable/tailscale_${version}_${DETECT_ARCH}.tgz"

# --- Step 5: Download & Extract ---
temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/$name.tgz"

# Extract tailscale and tailscaled, avoiding the top-level directory wrapper
tar -xzf "$temp_dir/$name.tgz" -C "$temp_dir" --strip-components=1 "tailscale_${version}_${DETECT_ARCH}/tailscale" "tailscale_${version}_${DETECT_ARCH}/tailscaled"

# --- Step 6: Install binary ---
if [ -f "$temp_dir/tailscale" ]; then
  install_binary "$temp_dir/tailscale" "/usr/local/bin/tailscale"
  install_binary "$temp_dir/tailscaled" "/usr/local/bin/tailscaled"
  rm -rf "$temp_dir"
  echo "$(green_bold ✓) $name installed successfully: $(bold "v${version}")"
else
  echo "$(red ✗ Failed to install $name.)"
  rm -rf "$temp_dir"
  exit 1
fi
