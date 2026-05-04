version=${args[--version]}
force=${args[--force]}

if [ -f "/usr/local/bin/kustomize" ] && [ -z "$force" ]; then
  echo "Error: Kustomize is already installed at /usr/local/bin/kustomize."
  echo "Use --force (or -f) to overwrite."
  exit 1
fi


# Strip leading 'v' if present for the kustomize install script which expects #.#.# format
script_version="$version"
if [[ "$script_version" == v* ]]; then
  script_version="${script_version:1}"
fi

echo "Installing Kustomize ($version)..."

temp_dir=$(mktemp -d)

if [[ "$script_version" == "latest" ]]; then
  curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | sed 's/curl -sLO/curl -#LO/' | bash -s -- "$temp_dir" > /dev/null
else
  curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | sed 's/curl -sLO/curl -#LO/' | bash -s -- "$script_version" "$temp_dir" > /dev/null
fi

if [ -f "$temp_dir/kustomize" ]; then
  if [ -w "/usr/local/bin" ]; then
    mv -f "$temp_dir/kustomize" /usr/local/bin/kustomize
  else
    sudo mv -f "$temp_dir/kustomize" /usr/local/bin/kustomize
  fi
  rm -rf "$temp_dir"
  echo "✓ Kustomize installed successfully: $(/usr/local/bin/kustomize version)"
else
  echo "Failed to install Kustomize."
  rm -rf "$temp_dir"
  exit 1
fi
