version=${args[--version]}
force=${args[--force]}
name="zsh"

# --- Step 1: Guard against overwrite ---
if command -v zsh >/dev/null 2>&1 && [ -z "$force" ]; then
  echo "$(red Error:) ${name} is already installed at $(command -v zsh)."
  echo "Use $(bold --force) (or $(bold -f)) to overwrite/reinstall."
  exit 1
fi

echo "Installing $(cyan_bold "$name") via package manager..."

# --- Step 2: Install via package manager ---
if install_package "$name"; then
  echo "$(green_bold ✓) $name installed successfully."
else
  echo "$(red ✗ Failed to install $name.)"
  exit 1
fi
