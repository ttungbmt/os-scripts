version=${args[--version]}
force=${args[--force]}
name="helmfile"
target="/usr/local/bin/helmfile"

guard_existing "$name" "$target" "$force"
echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "helmfile/helmfile")
fi
if [[ "$version" == v* ]]; then
  version="${version:1}"
fi

detect_platform
arch="$DETECT_ARCH"

# Asset: helmfile_{ver}_linux_amd64.tar.gz — bare helmfile inside
download_url="https://github.com/helmfile/helmfile/releases/download/v${version}/helmfile_${version}_linux_${arch}.tar.gz"

temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/helmfile.tar.gz"
tar -xzf "$temp_dir/helmfile.tar.gz" -C "$temp_dir" helmfile

if [ -f "$temp_dir/helmfile" ]; then
  install_binary "$temp_dir/helmfile" "$target"
  rm -rf "$temp_dir"
  echo "$(green_bold ✓) $name installed successfully: $(bold "v${version}")"
else
  rm -rf "$temp_dir"; echo "$(red ✗ Failed to install $name.)"; exit 1
fi
