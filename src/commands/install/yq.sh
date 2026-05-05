version=${args[--version]}
force=${args[--force]}
name="yq"
target="/usr/local/bin/yq"

guard_existing "$name" "$target" "$force"
echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "mikefarah/yq")
fi

detect_platform
arch="$DETECT_ARCH"
os="$DETECT_OS"

# Asset: bare binary yq_linux_amd64 (no archive)
download_url="https://github.com/mikefarah/yq/releases/download/${version}/yq_${os}_${arch}"

temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/yq"

if [ -f "$temp_dir/yq" ]; then
  install_binary "$temp_dir/yq" "$target"
  rm -rf "$temp_dir"
  echo "$(green_bold ✓) $name installed successfully: $(bold "${version}")"
else
  rm -rf "$temp_dir"; echo "$(red ✗ Failed to install $name.)"; exit 1
fi
