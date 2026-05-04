name="zsh"

if ! command -v zsh >/dev/null 2>&1; then
  echo "$(yellow ${name} is not installed)."
  exit 0
fi

echo -n "Are you sure you want to uninstall $(cyan_bold "${name}") via package manager? [y/N] "
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

echo "Uninstalling $(cyan_bold "${name}")..."

if remove_package "$name"; then
  echo "$(green_bold ✓) ${name} uninstalled successfully."
else
  echo "$(red ✗ Failed to uninstall ${name}.)"
  exit 1
fi
