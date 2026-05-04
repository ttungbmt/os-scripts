version=${args[--version]}
force=${args[--force]}
name="kustomize"
target="/usr/local/bin/kustomize"

guard_existing "$name" "$target" "$force"

echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

# Strip leading 'v' if present for the kustomize install script which expects #.#.# format
script_version="$version"
if [[ "$script_version" == v* ]]; then
  script_version="${script_version:1}"
fi

temp_dir=$(mktemp -d)

if [[ "$script_version" == "latest" ]]; then
  curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" \
    | sed 's/curl -sLO/curl -#LO/' \
    | bash -s -- "$temp_dir" > /dev/null
else
  curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" \
    | sed 's/curl -sLO/curl -#LO/' \
    | bash -s -- "$script_version" "$temp_dir" > /dev/null
fi

if [ -f "$temp_dir/kustomize" ]; then
  install_binary "$temp_dir/kustomize" "$target"
  rm -rf "$temp_dir"
  echo "$(green_bold ✓) $name installed successfully: $(bold "$($target version)")"
else
  echo "$(red ✗ Failed to install $name.)"
  rm -rf "$temp_dir"
  exit 1
fi
