## Template: Claude Code settings.json
## This file is located in 'src/lib/templates/claude.sh'

template_claude_settings() {
  cat <<'EOF'
{
  "permissions": {
    "allow": [
      "Bash(git status*)",
      "Bash(git log*)",
      "Bash(git diff*)",
      "Bash(git show*)",
      "Bash(git fetch*)",
      "Bash(git branch*)",
      "Bash(git checkout*)",
      "Bash(git pull*)",
      "Bash(git stash*)",
      "Bash(kubectl get *)",
      "Bash(kubectl describe *)",
      "Bash(kustomize build *)",
      "Bash(helm version *)",
      "Bash(helm list *)",
      "Bash(helm get *)",
      "Bash(helmfile --version)",
      "Bash(helmfile list *)",
      "Bash(helmfile template *)",
      "Bash(helmfile diff *)",
      "Bash(chmod +x *)"
    ],
    "defaultMode": "auto"
  },
  "effortLevel": "medium",
  "theme": "dark",
  "editorMode": "normal",
  "preferredNotifChannel": "auto",
  "skipAutoPermissionPrompt": true
}
EOF
}
