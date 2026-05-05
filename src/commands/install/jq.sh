version=${args[--version]}
force=${args[--force]}
name="jq"
target="/usr/local/bin/jq"

guard_existing "$name" "$target" "$force"
echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "jqlang/jq")
fi
# jq tags are like 'jq-1.8.1' — strip prefix for display but keep for URL
tag="$version"

detect_platform
arch="$DETECT_ARCH"
os="$DETECT_OS"

# Asset: bare binary jq-linux-amd64 (no archive)
download_url="https://github.com/jqlang/jq/releases/download/${tag}/jq-${os}-${arch}"

temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/jq"

if [ -f "$temp_dir/jq" ]; then
  install_binary "$temp_dir/jq" "$target"
  rm -rf "$temp_dir"
  echo "$(green_bold ✓) $name installed successfully: $(bold "${tag}")"
else
  rm -rf "$temp_dir"; echo "$(red ✗ Failed to install $name.)"; exit 1
fi
