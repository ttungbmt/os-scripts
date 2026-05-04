version=${args[--version]}
force=${args[--force]}
name="thefuck"
target="/usr/local/bin/thefuck"

# --- Step 1: Guard against overwrite ---
if [ -f "$target" ] || command -v thefuck >/dev/null 2>&1; then
  if [ -z "$force" ]; then
    echo "$(cyan_bold "$name") is already installed."
    echo "Use $(bold --force) to overwrite/upgrade."
    exit 0
  fi
fi

echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

# --- Step 2: Resolve version ---
# pip3 will handle versioning
pip_pkg="thefuck"
if [[ "$version" != "latest" ]]; then
  # Strip v if someone provided it
  if [[ "$version" == v* ]]; then
    version="${version:1}"
  fi
  pip_pkg="thefuck==$version"
fi

# --- Step 3: Install via pip3 ---
if ! command -v pip3 >/dev/null 2>&1; then
  echo "$(red "Error: pip3 is not installed. Please install python3-pip first.")"
  exit 1
fi

echo "Running pip3 install..."
if sudo pip3 install --upgrade "$pip_pkg"; then
  echo "$(green_bold ✓) $name installed successfully!"
else
  echo "$(red ✗ Failed to install $name.)"
  exit 1
fi
