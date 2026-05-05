version=${args[--version]}
force=${args[--force]}
name="nerdctl"
target="/usr/local/bin/nerdctl"

guard_existing "$name" "$target" "$force"
echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "containerd/nerdctl")
fi
if [[ "$version" == v* ]]; then
  version="${version:1}"
fi

detect_platform
arch="$DETECT_ARCH"

# Asset: nerdctl-{ver}-linux-amd64.tar.gz — bare nerdctl inside
download_url="https://github.com/containerd/nerdctl/releases/download/v${version}/nerdctl-${version}-linux-${arch}.tar.gz"

temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/nerdctl.tar.gz"
tar -xzf "$temp_dir/nerdctl.tar.gz" -C "$temp_dir" nerdctl

if [ -f "$temp_dir/nerdctl" ]; then
  install_binary "$temp_dir/nerdctl" "$target"
  rm -rf "$temp_dir"
  echo "$(green_bold ✓) $name installed successfully: $(bold "v${version}")"
else
  rm -rf "$temp_dir"; echo "$(red ✗ Failed to install $name.)"; exit 1
fi
