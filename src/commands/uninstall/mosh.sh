name="mosh"

if ! command -v mosh >/dev/null 2>&1; then
  echo "$(yellow ${name} is not installed.)"
  exit 0
fi

echo -n "Are you sure you want to uninstall $(cyan_bold "${name}")? [y/N] "
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

remove_package "$name"
echo "$(green_bold ✓) ${name} uninstalled."
