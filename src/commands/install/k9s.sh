version=${args[--version]}
force=${args[--force]}
name="k9s"
target="/usr/local/bin/k9s"

guard_existing "$name" "$target" "$force"

echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

# Fetch version if latest
if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "derailed/k9s")
fi

# Strip leading v
if [[ "$version" == v* ]]; then
  version="${version:1}"
fi

detect_platform

# k9s uses capitalized OS name (Linux, Darwin)
case "$DETECT_OS" in
  linux)  k9s_os="Linux" ;;
  darwin) k9s_os="Darwin" ;;
esac

download_url="https://github.com/derailed/k9s/releases/download/v${version}/k9s_${k9s_os}_${DETECT_ARCH}.tar.gz"

temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/k9s.tar.gz"
tar -xzf "$temp_dir/k9s.tar.gz" -C "$temp_dir" k9s

if [ -f "$temp_dir/k9s" ]; then
  install_binary "$temp_dir/k9s" "$target"
  rm -rf "$temp_dir"
  echo "$(green_bold ✓) $name installed successfully: $(bold "v${version}")"
else
  echo "$(red ✗ Failed to install $name.) Could not extract binary."
  rm -rf "$temp_dir"
  exit 1
fi
