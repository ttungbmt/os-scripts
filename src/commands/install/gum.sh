version=${args[--version]}
force=${args[--force]}
name="gum"
target="/usr/local/bin/gum"

guard_existing "$name" "$target" "$force"
echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "charmbracelet/gum")
fi
if [[ "$version" == v* ]]; then
  version="${version:1}"
fi

detect_platform
# gum uses x86_64/arm64, Linux/Darwin capitalized
arch="x86_64"
if [[ "$DETECT_ARCH" == "arm64" ]]; then arch="arm64"; fi
os="Linux"
if [[ "$DETECT_OS" == "darwin" ]]; then os="Darwin"; fi

# Asset: gum_{ver}_Linux_x86_64.tar.gz — nested gum_{ver}_Linux_x86_64/gum
download_url="https://github.com/charmbracelet/gum/releases/download/v${version}/gum_${version}_${os}_${arch}.tar.gz"
binary_path="gum_${version}_${os}_${arch}/gum"

temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/gum.tar.gz"
tar -xzf "$temp_dir/gum.tar.gz" -C "$temp_dir" "$binary_path"

if [ -f "$temp_dir/$binary_path" ]; then
  install_binary "$temp_dir/$binary_path" "$target"
  rm -rf "$temp_dir"
  echo "$(green_bold ✓) $name installed successfully: $(bold "v${version}")"
else
  rm -rf "$temp_dir"; echo "$(red ✗ Failed to install $name.)"; exit 1
fi
