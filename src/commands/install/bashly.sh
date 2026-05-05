version=${args[--version]}
force=${args[--force]}
name="bashly"

if command -v bashly >/dev/null 2>&1 && [ -z "$force" ]; then
  echo "$(red Error:) ${name} is already installed at $(command -v bashly)."
  echo "Use $(bold --force) (or $(bold -f)) to overwrite."
  exit 1
fi

echo "Installing $(cyan_bold "$name") via gem..."

gem_args=()
if [[ "$version" != "latest" ]]; then
  # Strip leading v if any
  ver="${version#v}"
  gem_args=(-v "$ver")
fi

if sudo gem install bashly "${gem_args[@]}"; then
  echo "$(green_bold ✓) $name installed successfully."
else
  echo "$(red ✗ Failed to install $name.)"
  exit 1
fi
