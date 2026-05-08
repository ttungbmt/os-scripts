name="bats"
target="/usr/local/share/bats"

if [ ! -d "$target" ]; then
  echo "$(yellow ${name} is not installed) at ${target}."
  exit 0
fi

echo -n "Are you sure you want to uninstall $(cyan_bold "${name}") at $target? [y/N] "
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

echo "Uninstalling $(cyan_bold "${name}")..."
remove_git_repo "$target"
remove_binary "/usr/local/bin/bats"

if [ ! -d "$target" ]; then
  echo "$(green_bold ✓) ${name} uninstalled successfully."
else
  echo "$(red ✗ Failed to uninstall ${name}.)"
  exit 1
fi
