version=${args[--version]}
force=${args[--force]}
name="chezmoi"
target="/usr/local/bin/chezmoi"

guard_existing "$name" "$target" "$force"
echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "twpayne/chezmoi")
fi
if [[ "$version" == v* ]]; then
  version="${version:1}"
fi

detect_platform
arch="$DETECT_ARCH"
os="$DETECT_OS"

# Asset: chezmoi_{ver}_linux_amd64.tar.gz — bare chezmoi inside
download_url="https://github.com/twpayne/chezmoi/releases/download/v${version}/chezmoi_${version}_${os}_${arch}.tar.gz"

temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/chezmoi.tar.gz"
tar -xzf "$temp_dir/chezmoi.tar.gz" -C "$temp_dir" chezmoi

if [ -f "$temp_dir/chezmoi" ]; then
  install_binary "$temp_dir/chezmoi" "$target"
  rm -rf "$temp_dir"
  echo "$(green_bold ✓) $name installed successfully: $(bold "v${version}")"
else
  rm -rf "$temp_dir"; echo "$(red ✗ Failed to install $name.)"; exit 1
fi
