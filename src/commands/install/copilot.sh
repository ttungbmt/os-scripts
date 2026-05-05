version=${args[--version]}
force=${args[--force]}
name="copilot"
target="/usr/local/bin/copilot"

# --- Step 1: Guard against overwrite ---
guard_existing "$name" "$target" "$force"

echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

# --- Step 2: Resolve version ---
if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "github/copilot-cli")
fi

if [[ "$version" == v* ]]; then
  version="${version:1}"
fi

# --- Step 3: Detect platform ---
detect_platform

arch="$DETECT_ARCH"
if [[ "$arch" == "amd64" ]]; then
  arch="x64"
fi

# --- Step 4: Build download URL ---
download_url="https://github.com/github/copilot-cli/releases/download/v${version}/copilot-${DETECT_OS}-${arch}.tar.gz"

# --- Step 5: Download & Extract ---
temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/$name.tar.gz"
tar -xzf "$temp_dir/$name.tar.gz" -C "$temp_dir" copilot

# --- Step 6: Install binary ---
if [ -f "$temp_dir/copilot" ]; then
  install_binary "$temp_dir/copilot" "$target"
  rm -rf "$temp_dir"
  echo "$(green_bold ✓) $name installed successfully: $(bold "v${version}")"
else
  echo "$(red ✗ Failed to install $name.)"
  rm -rf "$temp_dir"
  exit 1
fi
