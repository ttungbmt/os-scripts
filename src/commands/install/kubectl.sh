version=${args[--version]}
force=${args[--force]}
name="kubectl"
target="/usr/local/bin/kubectl"

guard_existing "$name" "$target" "$force"

echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

# Fetch version if latest
if [[ "$version" == "latest" ]]; then
  version=$(curl -sL https://dl.k8s.io/release/stable.txt)
  if [ -z "$version" ]; then
    echo "$(red Error:) Could not fetch latest kubectl version."
    exit 1
  fi
else
  # Ensure it starts with v
  if [[ "$version" != v* ]]; then
    version="v${version}"
  fi
fi

detect_platform
download_url="https://dl.k8s.io/release/${version}/bin/${DETECT_OS}/${DETECT_ARCH}/kubectl"

temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/kubectl"
install_binary "$temp_dir/kubectl" "$target"
rm -rf "$temp_dir"

echo "$(green_bold ✓) $name installed successfully: $(bold "$version")"
