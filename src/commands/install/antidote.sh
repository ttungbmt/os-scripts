version=${args[--version]}
force=${args[--force]}
name="antidote"
repo_url="https://github.com/mattmc3/antidote.git"
target="/usr/local/share/antidote"

# --- Step 1: Guard against overwrite ---
if [ -d "$target" ] && [ -z "$force" ]; then
  echo "$(red Error:) ${name} is already installed at ${target}."
  echo "Use $(bold --force) (or $(bold -f)) to update/overwrite."
  exit 1
fi

echo "Installing $(cyan_bold "$name")..."

# --- Step 2: Resolve version ---
if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "mattmc3/antidote")
fi

# --- Step 3: Install via git clone ---
if install_git_repo "$repo_url" "$target" "$version"; then
  echo "$(green_bold ✓) $name installed successfully at $target."
  echo "To use it, add this to your ~/.zshrc:"
  echo "$(yellow "source ${target}/antidote.zsh")"
else
  echo "$(red ✗ Failed to install $name.)"
  exit 1
fi
