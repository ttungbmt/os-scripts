version=${args[--version]}
force=${args[--force]}
name="talisman"
target="/usr/local/bin/talisman"

# --- Step 1: Guard against overwrite ---
guard_existing "$name" "$target" "$force"

echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

# --- Step 2: Resolve version ---
if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "thoughtworks/talisman")
fi

if [[ "$version" == v* ]]; then
  version="${version:1}"
fi

# --- Step 3: Detect platform ---
detect_platform

# --- Step 4: Build download URL ---
download_url="https://github.com/thoughtworks/talisman/releases/download/v${version}/talisman_${DETECT_OS}_${DETECT_ARCH}"

# --- Step 5: Download & Install ---
temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/$name"

if [ -f "$temp_dir/$name" ]; then
  install_binary "$temp_dir/$name" "$target"
  rm -rf "$temp_dir"
  echo "$(green_bold ✓) $name installed successfully: $(bold "v${version}")"
else
  echo "$(red ✗ Failed to install $name.)"
  rm -rf "$temp_dir"
  exit 1
fi
