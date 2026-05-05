name="tailscale"
target_cli="/usr/local/bin/tailscale"
target_daemon="/usr/local/bin/tailscaled"

if [ ! -f "$target_cli" ] && [ ! -f "$target_daemon" ]; then
  echo "$(yellow ${name} is not installed.)"
  exit 0
fi

echo -n "Are you sure you want to uninstall $(cyan_bold "${name}")? [y/N] "
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

echo "Uninstalling $(cyan_bold "${name}")..."
remove_binary "$target_cli"
remove_binary "$target_daemon"

if [ ! -f "$target_cli" ] && [ ! -f "$target_daemon" ]; then
  echo "$(green_bold ✓) ${name} uninstalled successfully."
else
  echo "$(red ✗ Failed to uninstall ${name}.)"
  exit 1
fi
