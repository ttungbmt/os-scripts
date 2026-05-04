name="thefuck"
target=$(command -v thefuck)

if [ -z "$target" ]; then
  echo "$(cyan_bold "$name") is not installed."
  exit 0
fi

echo "Uninstalling $(cyan_bold "$name")..."
if sudo pip3 uninstall -y thefuck; then
  echo "$(green_bold ✓) $name uninstalled successfully."
else
  echo "$(red ✗ Failed to uninstall $name.)"
  exit 1
fi
