version=${args[--version]}
force=${args[--force]}
name="hyperfine"
target="/usr/local/bin/hyperfine"

guard_existing "$name" "$target" "$force"
echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "sharkdp/hyperfine")
fi
if [[ "$version" != v* ]]; then
  version="v${version}"
fi

detect_platform
arch="x86_64"
if [[ "$DETECT_ARCH" == "arm64" ]]; then arch="aarch64"; fi

# Asset: hyperfine-v{ver}-x86_64-unknown-linux-musl.tar.gz
# Binary nested: hyperfine-v{ver}-x86_64-.../hyperfine
download_url="https://github.com/sharkdp/hyperfine/releases/download/${version}/hyperfine-${version}-${arch}-unknown-linux-musl.tar.gz"
binary_path="hyperfine-${version}-${arch}-unknown-linux-musl/hyperfine"

temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/hyperfine.tar.gz"
tar -xzf "$temp_dir/hyperfine.tar.gz" -C "$temp_dir" "$binary_path"

if [ -f "$temp_dir/$binary_path" ]; then
  install_binary "$temp_dir/$binary_path" "$target"
  rm -rf "$temp_dir"
  echo "$(green_bold ✓) $name installed successfully: $(bold "${version}")"
else
  rm -rf "$temp_dir"; echo "$(red ✗ Failed to install $name.)"; exit 1
fi
