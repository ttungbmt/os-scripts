version=${args[--version]}
force=${args[--force]}
name="helm"
target="/usr/local/bin/helm"

guard_existing "$name" "$target" "$force"
echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "helm/helm")
fi
# helm URL always includes v prefix
if [[ "$version" != v* ]]; then
  version="v${version}"
fi

detect_platform
arch="$DETECT_ARCH"
os="$DETECT_OS"

# Asset: helm-v{ver}-linux-amd64.tar.gz — binary at linux-amd64/helm
download_url="https://get.helm.sh/helm-${version}-${os}-${arch}.tar.gz"

temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/helm.tar.gz"
tar -xzf "$temp_dir/helm.tar.gz" -C "$temp_dir" "${os}-${arch}/helm"

binary_path="${os}-${arch}/helm"
if [ -f "$temp_dir/$binary_path" ]; then
  install_binary "$temp_dir/$binary_path" "$target"
  rm -rf "$temp_dir"
  echo "$(green_bold ✓) $name installed successfully: $(bold "${version}")"
else
  rm -rf "$temp_dir"; echo "$(red ✗ Failed to install $name.)"; exit 1
fi
