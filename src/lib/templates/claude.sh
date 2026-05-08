## Template: Claude Code settings.json
## This file is located in 'src/lib/templates/claude.sh'

template_claude_settings() {
  cat <<'EOF'
{
  "enabledPlugins": {
    "skill-creator@claude-plugins-official": true,
    "superpowers@superpowers-marketplace": true,
    "claude-mem@thedotmack": true
  },
  "extraKnownMarketplaces": {
    "superpowers-marketplace": {
      "source": {
        "source": "github",
        "repo": "obra/superpowers-marketplace"
      }
    },
    "thedotmack": {
      "source": {
        "source": "github",
        "repo": "thedotmack/claude-mem"
      }
    },
    "claude-code-workflows": {
      "source": {
        "source": "github",
        "repo": "wshobson/agents"
      }
    }
  },
  "theme": "auto",
  "permissions": {
    "defaultMode": "auto",
    "allow": [],
    "ask": [],
    "deny": []
  }
}
EOF
}
