version=${args[--version]}
force=${args[--force]}
name="viddy"
target="/usr/local/bin/viddy"

guard_existing "$name" "$target" "$force"
echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "sachaos/viddy")
fi
# viddy URL includes v prefix
if [[ "$version" != v* ]]; then
  version="v${version}"
fi

detect_platform
# viddy uses x86_64/arm64
arch="x86_64"
if [[ "$DETECT_ARCH" == "arm64" ]]; then arch="arm64"; fi
os="linux"
if [[ "$DETECT_OS" == "darwin" ]]; then os="darwin"; fi

# Asset: viddy-v{ver}-linux-x86_64.tar.gz — bare viddy inside
download_url="https://github.com/sachaos/viddy/releases/download/${version}/viddy-${version}-${os}-${arch}.tar.gz"

temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/viddy.tar.gz"
tar -xzf "$temp_dir/viddy.tar.gz" -C "$temp_dir" viddy

if [ -f "$temp_dir/viddy" ]; then
  install_binary "$temp_dir/viddy" "$target"
  rm -rf "$temp_dir"
  echo "$(green_bold ✓) $name installed successfully: $(bold "${version}")"
else
  rm -rf "$temp_dir"; echo "$(red ✗ Failed to install $name.)"; exit 1
fi
