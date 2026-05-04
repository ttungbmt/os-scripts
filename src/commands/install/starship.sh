version=${args[--version]}
force=${args[--force]}
name="starship"
target="/usr/local/bin/starship"

# --- Step 1: Guard against overwrite ---
guard_existing "$name" "$target" "$force"

echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

# --- Step 2: Resolve version ---
if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "starship/starship")
fi

# Strip 'v' prefix for URL construction
if [[ "$version" == v* ]]; then
  version="${version:1}"
fi

# --- Step 3: Detect platform ---
detect_platform

# Map architecture (starship uses x86_64/aarch64)
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
download_url="https://github.com/starship/starship/releases/download/v${version}/starship-${arch}-${os}.tar.gz"

# --- Step 5: Download & extract ---
temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/starship.tar.gz"
tar -xzf "$temp_dir/starship.tar.gz" -C "$temp_dir" starship

# --- Step 6: Install binary ---
if [ -f "$temp_dir/starship" ]; then
  install_binary "$temp_dir/starship" "$target"
  rm -rf "$temp_dir"
  echo "$(green_bold ✓) $name installed successfully: $(bold "v${version}")"
else
  echo "$(red ✗ Failed to install $name.)"
  rm -rf "$temp_dir"
  exit 1
fi
