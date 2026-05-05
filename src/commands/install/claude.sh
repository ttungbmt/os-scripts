version=${args[--version]}
force=${args[--force]}
name="claude"

if command -v claude >/dev/null 2>&1 && [ -z "$force" ]; then
  echo "$(red Error:) ${name} is already installed at $(command -v claude)."
  echo "Use $(bold --force) (or $(bold -f)) to overwrite."
  exit 1
fi

echo "Installing $(cyan_bold "$name") via npm..."

if [[ "$version" != "latest" ]]; then
  ver="${version#v}"
  npm_pkg="@anthropic-ai/claude-code@$ver"
else
  npm_pkg="@anthropic-ai/claude-code"
fi

if npm install -g "$npm_pkg"; then
  echo "$(green_bold ✓) $name installed successfully."
else
  echo "$(red ✗ Failed to install $name.)"
  exit 1
fi
