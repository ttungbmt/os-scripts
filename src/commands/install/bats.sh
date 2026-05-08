version=${args[--version]}
force=${args[--force]}
name="bats"
repo_url="https://github.com/bats-core/bats-core.git"
target="/usr/local/share/bats"

# Guard: check if directory already exists
if [ -d "$target" ] && [ -z "$force" ]; then
  echo "$(red Error:) ${name} is already installed at ${target}."
  echo "Use $(bold --force) (or $(bold -f)) to update/overwrite."
  exit 1
fi

echo "Installing $(cyan_bold "$name")..."

# Resolve version
if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "bats-core/bats-core")
fi

# Clone or update
if install_git_repo "$repo_url" "$target" "$version"; then
  sudo ln -sf "$target/bin/bats" /usr/local/bin/bats
  echo "$(green_bold ✓) $name installed successfully at $target."
else
  echo "$(red ✗ Failed to install $name.)"
  exit 1
fi
