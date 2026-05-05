## Setup helpers for CLI tools
## This file is located in 'src/lib/setup_helpers.sh'

# Inject a block of text into a file if a marker is not already present
# Usage: inject_config_block "$target_file" "$marker" "$content"
inject_config_block() {
  local target_file="$1" marker="$2" content="$3"
  
  if grep -qF "$marker" "$target_file" 2>/dev/null; then
    echo "$(yellow "⚠") Config block already exists in $target_file — skipping"
    return 0
  fi
  
  # Create file if it doesn't exist
  [ -f "$target_file" ] || touch "$target_file"
  
  # Append the content
  printf '\n%s\n' "$content" >> "$target_file"
  echo "$(green_bold "✓") Config block added to $target_file"
}

# Inject a tool's shell-init block into both ~/.zshrc and ~/.bashrc.
# Skips files that don't exist (i.e. shells the user doesn't use). Idempotent
# via the marker passed to inject_config_block.
# Usage: setup_shell_tool "name" "$marker" "$zsh_block" "$bash_block"
setup_shell_tool() {
  local name="$1" marker="$2" zsh_block="$3" bash_block="$4"
  local zshrc="${ZDOTDIR:-$HOME}/.zshrc"
  local bashrc="$HOME/.bashrc"

  if [ -f "$zshrc" ]; then
    inject_config_block "$zshrc" "$marker" "$zsh_block"
  else
    echo "$(yellow "⚠") $zshrc does not exist — skipping zsh"
  fi

  if [ -f "$bashrc" ]; then
    inject_config_block "$bashrc" "$marker" "$bash_block"
  else
    echo "$(yellow "⚠") $bashrc does not exist — skipping bash"
  fi
}

# Seed a file with content if the file is empty or does not exist
# Usage: seed_file "$target_file" "$content"
seed_file() {
  local target_file="$1" content="$2"
  
  if [ -s "$target_file" ]; then
    echo "$(yellow "⚠") $target_file already has content — skipping (delete it first to re-seed)"
    return 0
  fi
  
  # Create parent directories if they don't exist
  mkdir -p "$(dirname "$target_file")"
  
  # Write content
  printf '%s\n' "$content" > "$target_file"
  echo "$(green_bold "✓") Seeded $target_file"
}
