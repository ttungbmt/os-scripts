name="gem"

if ! command -v gem >/dev/null 2>&1; then
  echo "$(yellow ${name} is not installed.)"
  exit 0
fi

echo -n "Are you sure you want to uninstall $(cyan_bold "${name}")? [y/N] "
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

if command -v apt-get >/dev/null 2>&1; then
  pkg="ruby-dev ruby rubygems"
elif command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
  pkg="ruby-devel ruby rubygems"
elif command -v pacman >/dev/null 2>&1; then
  pkg="ruby"
elif command -v apk >/dev/null 2>&1; then
  pkg="ruby-dev ruby"
else
  echo "$(red ✗) Could not detect a supported package manager."
  exit 1
fi

remove_package "$pkg"
echo "$(green_bold ✓) ${name} uninstalled."
