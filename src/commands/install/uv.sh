version=${args[--version]}
force=${args[--force]}
name="uv"
target="/usr/local/bin/uv"

guard_existing "$name" "$target" "$force"
echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "astral-sh/uv")
fi
# uv tags have no v prefix (e.g., 0.11.8)
version="${version#v}"

detect_platform
arch="x86_64"
if [[ "$DETECT_ARCH" == "arm64" ]]; then arch="aarch64"; fi

# Asset: uv-x86_64-unknown-linux-musl.tar.gz — nested uv-x86_64-.../uv
download_url="https://github.com/astral-sh/uv/releases/download/${version}/uv-${arch}-unknown-linux-musl.tar.gz"
binary_path="uv-${arch}-unknown-linux-musl/uv"

temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/uv.tar.gz"
tar -xzf "$temp_dir/uv.tar.gz" -C "$temp_dir" "$binary_path"

if [ -f "$temp_dir/$binary_path" ]; then
  install_binary "$temp_dir/$binary_path" "$target"
  rm -rf "$temp_dir"
  echo "$(green_bold ✓) $name installed successfully: $(bold "${version}")"
else
  rm -rf "$temp_dir"; echo "$(red ✗ Failed to install $name.)"; exit 1
fi
