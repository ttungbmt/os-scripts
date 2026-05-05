version=${args[--version]}
force=${args[--force]}
name="ksops"
target="/usr/local/bin/ksops"

guard_existing "$name" "$target" "$force"
echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "viaduct-ai/kustomize-sops")
fi
if [[ "$version" == v* ]]; then
  version="${version:1}"
fi

detect_platform
arch="x86_64"
if [[ "$DETECT_ARCH" == "arm64" ]]; then arch="arm64"; fi
os="Linux"
if [[ "$DETECT_OS" == "darwin" ]]; then os="Darwin"; fi

# Asset: ksops_{ver}_Linux_x86_64.tar.gz — bare ksops inside
download_url="https://github.com/viaduct-ai/kustomize-sops/releases/download/v${version}/ksops_${version}_${os}_${arch}.tar.gz"

temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/ksops.tar.gz"
tar -xzf "$temp_dir/ksops.tar.gz" -C "$temp_dir" ksops

if [ -f "$temp_dir/ksops" ]; then
  install_binary "$temp_dir/ksops" "$target"
  rm -rf "$temp_dir"
  echo "$(green_bold ✓) $name installed successfully: $(bold "v${version}")"
else
  rm -rf "$temp_dir"; echo "$(red ✗ Failed to install $name.)"; exit 1
fi
