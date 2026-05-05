force=${args[--force]}
name="gem"

# Guard
if command -v gem >/dev/null 2>&1 && [ -z "$force" ]; then
  echo "$(red Error:) ${name} is already installed at $(command -v gem)."
  echo "Use $(bold --force) (or $(bold -f)) to overwrite/reinstall."
  exit 1
fi

echo "Installing $(cyan_bold "$name") via package manager..."

if command -v apt-get >/dev/null 2>&1; then
  pkg="ruby-dev"
elif command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
  pkg="ruby-devel"
elif command -v pacman >/dev/null 2>&1; then
  pkg="ruby"
elif command -v apk >/dev/null 2>&1; then
  pkg="ruby-dev"
else
  echo "$(red ✗) Could not detect a supported package manager."
  exit 1
fi

if install_package "$pkg"; then
  echo "$(green_bold ✓) $name installed successfully."
else
  echo "$(red ✗ Failed to install $name.)"
  exit 1
fi
