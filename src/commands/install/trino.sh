version=${args[--version]}
force=${args[--force]}
name="trino"
target="/usr/local/bin/trino"

guard_existing "$name" "$target" "$force"
echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "trinodb/trino")
fi
# trino tags have no v prefix (e.g., 480)
version="${version#v}"

# Asset: trino-cli-{ver}-executable.jar (self-executable jar)
download_url="https://repo1.maven.org/maven2/io/trino/trino-cli/${version}/trino-cli-${version}-executable.jar"

temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/trino"

if [ -f "$temp_dir/trino" ]; then
  install_binary "$temp_dir/trino" "$target"
  rm -rf "$temp_dir"
  echo "$(green_bold ✓) $name installed successfully: $(bold "${version}")"
else
  rm -rf "$temp_dir"; echo "$(red ✗ Failed to install $name.)"; exit 1
fi
