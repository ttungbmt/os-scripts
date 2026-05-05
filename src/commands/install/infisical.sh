version=${args[--version]}
force=${args[--force]}
name="infisical"
target="/usr/local/bin/infisical"

guard_existing "$name" "$target" "$force"
echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "Infisical/cli")
fi
if [[ "$version" == v* ]]; then
  version="${version:1}"
fi

detect_platform
arch="$DETECT_ARCH"

# Asset: cli_{ver}_linux_amd64.tar.gz — bare infisical inside
download_url="https://github.com/Infisical/cli/releases/download/v${version}/cli_${version}_linux_${arch}.tar.gz"

temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/infisical.tar.gz"
tar -xzf "$temp_dir/infisical.tar.gz" -C "$temp_dir" infisical

if [ -f "$temp_dir/infisical" ]; then
  install_binary "$temp_dir/infisical" "$target"
  rm -rf "$temp_dir"
  echo "$(green_bold ✓) $name installed successfully: $(bold "v${version}")"
else
  rm -rf "$temp_dir"; echo "$(red ✗ Failed to install $name.)"; exit 1
fi
