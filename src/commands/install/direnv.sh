version=${args[--version]}
force=${args[--force]}
name="direnv"
target="/usr/local/bin/direnv"

# --- Step 1: Guard against overwrite ---
guard_existing "$name" "$target" "$force"

echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

# --- Step 2: Resolve version ---
if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "direnv/direnv")
fi

# Strip 'v' prefix for some parsing if needed, but here we need it for download URL
if [[ "$version" == v* ]]; then
  version="${version:1}"
fi

# --- Step 3: Detect platform ---
detect_platform

# --- Step 4: Build download URL ---
# Note: direnv uses v prefix in the URL
download_url="https://github.com/direnv/direnv/releases/download/v${version}/direnv.${DETECT_OS}-${DETECT_ARCH}"

# --- Step 5: Download & install ---
temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/direnv"
install_binary "$temp_dir/direnv" "$target"
rm -rf "$temp_dir"

echo "$(green_bold ✓) $name installed successfully: $(bold "v${version}")"
