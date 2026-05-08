# Claude Code Comprehensive Cheatsheet

> Complete reference for Claude Code CLI, slash commands, configuration, and features.
> Updated May 2026 | Claude Code v2.1.128+

## Quick Navigation

1. [Installation & Setup](#installation--setup)
2. [CLI Commands & Flags](#cli-commands--flags)
3. [Slash Commands](#slash-commands)
4. [Keyboard Shortcuts](#keyboard-shortcuts)
5. [Settings & Configuration](#settings--configuration)
6. [CLAUDE.md & Memory](#claudemd--memory)
7. [MCP Servers](#mcp-servers)
8. [Hooks](#hooks)
9. [Permissions System](#permissions-system)
10. [Skills](#skills)
11. [Models & Effort Levels](#models--effort-levels)
12. [IDE Integrations](#ide-integrations)
13. [Advanced Features](#advanced-features)

---

## Installation & Setup

### Installation Methods

```bash
# macOS, Linux, WSL
curl -fsSL https://claude.ai/install.sh | bash

# Windows PowerShell
irm https://claude.ai/install.ps1 | iex

# Windows CMD
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd

# Homebrew
brew install --cask claude-code          # stable
brew install --cask claude-code@latest   # rolling

# WinGet
winget install Anthropic.ClaudeCode

# npm
npm install -g @anthropic-ai/claude-code

# apt (Debian/Ubuntu)
sudo apt install claude-code

# dnf (Fedora/RHEL)
sudo dnf install claude-code

# apk (Alpine)
apk add claude-code
```

### System Requirements

- **OS**: macOS 13+, Windows 10 1809+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+
- **Hardware**: 4GB+ RAM, x64 or ARM64
- **Shell**: Bash, Zsh, PowerShell, or CMD
- **Network**: Internet connection required
- **Location**: Anthropic-supported countries

### First Steps

```bash
# Verify installation
claude --version

# Run diagnostics
claude doctor

# Start session (triggers login if needed)
claude
```

---

## CLI Commands & Flags

### Basic Commands

```bash
claude                          # Start interactive session
claude -p "prompt"             # Non-interactive (headless) mode
claude --help                  # Show help
claude --version               # Show version number
claude doctor                  # Run diagnostics
claude update                  # Check/install updates
claude login                   # Authenticate
claude logout                  # Sign out
```

### Session Control Flags

```bash
--continue                     # Continue most recent conversation
--resume <session-id>          # Resume specific session
--fork                         # Fork current conversation
--repository <path>            # Work in specific repository
--cwd <path>                   # Set working directory
--add-dir <path>              # Add additional directory
```

### Model & Effort Flags

```bash
--model <name>                 # Set model (opus, sonnet, haiku, default)
--effort <level>               # Set effort (low, medium, high, xhigh, max)
```

### Permissions & Tools Flags

```bash
--allowedTools <tools>         # Pre-approve tools (comma-separated)
--disallowedTools <tools>      # Block tools
--permission-mode <mode>       # Permission mode (default, plan, acceptEdits, auto, dontAsk, bypassPermissions)
```

### Configuration Flags

```bash
--settings <file|json>         # Load settings
--bare                         # Skip auto-discovery
--add-environment VAR=VALUE    # Set environment variables
--append-system-prompt <text>  # Add to system prompt
--append-system-prompt-file    # Add system prompt from file
--system-prompt <text>         # Replace system prompt
```

### Output Format Flags (Non-interactive)

```bash
-p, --print                    # Non-interactive mode
--output-format <format>       # text, json, stream-json
--json-schema <schema>         # Structure output as JSON
--include-partial-messages     # Include token stream
--verbose                      # Detailed output
```

### MCP & Plugin Flags

```bash
--mcp-config <file|json>       # Load MCP servers
--plugin-dir <path>            # Load plugin from directory
--plugin-url <url>             # Load plugin from URL
```

---

## Slash Commands

Type `/` to list all commands. Filter with `/letters`.

### Core Commands (Built-in)

```bash
/help                          # Show all commands
/clear                         # Clear conversation
/compact                       # Compress context
/config                        # Settings UI
/status                        # Session info & usage
/memory                        # Browse CLAUDE.md & auto memory
/init                          # Initialize CLAUDE.md
/doctor                        # Diagnostics
/bugs                          # Report bugs
/feedback                      # Send feedback
```

### Model & Mode Commands

```bash
/model [alias|name]            # Change model or open picker
/effort [level|auto]           # Set effort level
/vim                           # Toggle vim mode
/fast                          # Toggle fast mode
```

### Permission & Tool Commands

```bash
/permissions                   # Manage permissions
/mcp                           # Manage MCP servers
/add-dir <path>               # Add directory for session
```

### Subagent & Plugin Commands

```bash
/agents                        # Manage custom subagents
/plugins                       # Discover/manage plugins
/skills                        # Manage skills
/hooks                         # View configured hooks
```

### IDE & Setup Commands

```bash
/ide                           # Open in VS Code/JetBrains
/terminal-setup                # Configure terminal
/web-setup                     # Set up cloud environments
/voice                         # Enable voice dictation
/desktop                       # Open in Desktop app
```

### Code Review & Analysis Commands

```bash
/review                        # Local code review
/ultrareview                   # Deep review (web)
/security-review               # Security audit
```

### Utility Commands

```bash
/login                         # Authenticate
/logout                        # Sign out
/pr-comments <repo>           # Get PR comments
/release-notes                 # Show release notes
/statusline                    # Configure status line
/btw <message>                # Ask side question
/task [description]           # Create background task
```

### Bundled Skills (AI-Powered)

```bash
/simplify                      # Review code for efficiency
/batch <description>          # Plan large changes in worktrees
/debug                         # Debug issue
/loop [interval]               # Run prompt repeatedly
/schedule                      # Create scheduled routines
/claude-api                    # Build/debug Claude API apps
/update-config                 # Configure harness & hooks
/keybindings-help              # Customize keyboard shortcuts
/fewer-permission-prompts      # Add allowlist from transcript
```

---

## Keyboard Shortcuts

### Global Shortcuts

| Key | Action |
|-----|--------|
| `Ctrl+C` | Cancel current operation |
| `Ctrl+D` | Exit Claude Code |
| `Ctrl+R` | Search command history |
| `Ctrl+T` | Toggle task list |
| `Ctrl+O` | Toggle verbose transcript |

### Chat Input Shortcuts

| Key | Action |
|-----|--------|
| `Enter` | Submit message |
| `Ctrl+J` | Insert newline |
| `Shift+Tab` | Cycle permission modes |
| `Escape` | Cancel input |
| `Ctrl+U` / `Ctrl+_` | Undo |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | External editor |
| `Ctrl+S` | Stash prompt |
| `Ctrl+V` | Paste image |
| `Ctrl+L` | Redraw (preserve input) |
| `Meta+P` | Model picker |
| `Meta+O` | Toggle fast mode |
| `Meta+T` | Toggle thinking |
| `Ctrl+X Ctrl+K` | Kill agents |

### Navigation

| Key | Action |
|-----|--------|
| `Up/Down` | History |
| `Tab` | Accept autocomplete |
| `Escape` | Dismiss autocomplete |

### Customize Keybindings

File: `~/.claude/keybindings.json`

```json
{
  "$schema": "https://www.schemastore.org/claude-code-keybindings.json",
  "bindings": [
    {
      "context": "Chat",
      "bindings": {
        "ctrl+e": "chat:externalEditor",
        "ctrl+k": "chat:submit",
        "ctrl+u": null
      }
    }
  ]
}
```

---

## Settings & Configuration

### Configuration Scopes (Priority Order)

1. Managed settings (highest - cannot override)
2. Command-line arguments
3. Local project (`.claude/settings.local.json`)
4. Shared project (`.claude/settings.json`)
5. User settings (lowest - `~/.claude/settings.json`)

### Settings Files Location

- **User**: `~/.claude/settings.json`
- **Project**: `.claude/settings.json`
- **Project local**: `.claude/settings.local.json` (gitignored)
- **Managed (macOS)**: `/Library/Application Support/ClaudeCode/settings.json`
- **Managed (Linux/WSL)**: `/etc/claude-code/settings.json`
- **Managed (Windows)**: `C:\Program Files\ClaudeCode\settings.json`

### Essential Settings

```json
{
  "model": "claude-sonnet-4-6",
  "effortLevel": "high",
  "alwaysThinkingEnabled": true,
  
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(git * main)",
      "Read(~/.zshrc)",
      "WebFetch(domain:github.com)"
    ],
    "deny": ["Bash(rm -rf *)"],
    "defaultMode": "default"
  },
  
  "autoMemoryEnabled": true,
  "editorMode": "vim",
  "theme": "dark",
  "preferredNotifChannel": "auto",
  
  "sandbox": {
    "enabled": true,
    "filesystem": {
      "allowWrite": ["/tmp/build"],
      "denyRead": ["~/.ssh"]
    }
  },
  
  "env": {
    "CUSTOM_VAR": "value"
  }
}
```

---

## CLAUDE.md & Memory

### CLAUDE.md Purpose

Persistent instructions loaded at every session start. Write once, reuse everywhere:
- Build & test commands
- Code conventions
- Project architecture
- Common workflows
- Decision rationale

### CLAUDE.md Locations & Scope

| Location | Scope | Loaded | Use Case |
|----------|-------|--------|----------|
| Managed policy location | Organization | All users | Company standards |
| `./CLAUDE.md` | Project | Team via git | Project standards |
| `./CLAUDE.local.md` | Personal | Just you | Personal preferences |
| `~/.claude/CLAUDE.md` | User | All projects | Personal preferences |

### CLAUDE.md Best Practices

- **Size**: Target <200 lines (consumes context tokens)
- **Structure**: Use markdown headers and bullets
- **Specificity**: Be concrete, not vague
- **Consistency**: Review for conflicting rules

### Example CLAUDE.md

```markdown
# Build & Test

- Build: `npm run build`
- Test: `npm test`
- Dev: `npm run dev`

## Code Style

- 2-space indentation
- TypeScript for new files
- Components in `src/components/`
- Tests colocated as `*.test.ts`

## Key Conventions

- React 18+ with hooks
- Standard error responses
- Validation on all inputs

@README
@package.json for npm commands
```

### Path-Specific Rules (`.claude/rules/`)

Create files that load only when editing matching paths:

File: `.claude/rules/api.md`
```yaml
---
paths:
  - "src/api/**/*.ts"
---

# API Development Rules

- Validate all inputs
- Return standard error format
- Include OpenAPI docs
```

### Auto Memory

Claude's machine-local learning. Automatically saves insights.

**Storage**: `~/.claude/projects/<project>/memory/`

**File structure**:
```
memory/
├── MEMORY.md          # Index (loaded at startup, first 200 lines)
├── debugging.md       # Topic file
└── patterns.md        # Topic file
```

**Enable/disable**:
```json
{
  "autoMemoryEnabled": true,
  "autoMemoryDirectory": "~/.claude/memory"
}
```

**View/edit**: Use `/memory` command

---

## MCP Servers

### What is MCP?

Model Context Protocol - integrate external tools, APIs, databases.

### Adding MCP Servers

**File**: `.mcp.json` (project root) or `~/.claude/.mcp.json` (user)

```json
{
  "mcpServers": {
    "github": {
      "type": "stdio",
      "command": "python3",
      "args": ["-m", "anthropic.github_mcp_server"]
    },
    "postgres": {
      "type": "stdio",
      "command": "npx",
      "args": ["postgres-mcp-server"]
    },
    "remote-api": {
      "type": "sse",
      "url": "https://api.example.com/mcp"
    },
    "http-api": {
      "type": "http",
      "url": "http://localhost:3000"
    }
  }
}
```

### MCP Server Types

- **stdio**: Local process (Node.js, Python)
- **sse**: Remote server (Server-Sent Events)
- **http**: Remote HTTP API

### Permissions for MCP Tools

```json
{
  "permissions": {
    "allow": [
      "mcp__github__*",
      "mcp__postgres__query_db"
    ],
    "deny": [
      "mcp__stripe__charge"
    ]
  }
}
```

### Check Connected Servers

```bash
/status    # Shows all connected MCP servers
/mcp       # Manage MCP servers
```

---

## Hooks

### What are Hooks?

Deterministic shell commands executed at lifecycle events. Enforce rules, automate tasks.

### Lifecycle Events

- `SessionStart` - Session begins
- `PreToolUse` - Before tool execution
- `PostToolUse` - After tool execution
- `PostToolUseFailure` - Tool failed
- `PermissionRequest` - Permission needed
- `UserPromptSubmit` - User submits prompt
- `FileChanged` - File modified
- `ConfigChange` - Settings changed
- `Stop` - Session ending
- `SubagentStart` / `SubagentStop`
- `TaskCreated` / `TaskCompleted`
- `PreCompact` / `PostCompact`

### Hook Configuration

File: `.claude/settings.json` or `~/.claude/settings.json`

```json
{
  "hooks": [
    {
      "event": "PostToolUse",
      "if": "toolName == 'Edit'",
      "handler": {
        "type": "command",
        "command": "prettier",
        "args": ["--write", "{filePath}"]
      }
    },
    {
      "event": "SessionStart",
      "handler": {
        "type": "command",
        "command": "bash",
        "args": ["-c", "echo 'Session started'"]
      }
    }
  ]
}
```

### Handler Types

**Command (Shell)**:
```json
{
  "type": "command",
  "command": "bash",
  "args": ["-c", "echo 'Running'"]
}
```

**Prompt (AI)**:
```json
{
  "type": "prompt",
  "system": "You are a code reviewer",
  "prompt": "Review this change"
}
```

**HTTP (Webhook)**:
```json
{
  "type": "http",
  "url": "https://api.example.com/hooks",
  "method": "POST"
}
```

### Hook Exit Codes

- **0**: Allow (continue)
- **1**: Deny (block)
- **2**: Prompt (ask user)

---

## Permissions System

### Permission Modes

| Mode | Behavior |
|------|----------|
| `default` | Prompt on first use |
| `plan` | Read-only tools only |
| `acceptEdits` | Auto-approve file edits |
| `auto` | Auto-approve with checks |
| `dontAsk` | Deny unless pre-approved |
| `bypassPermissions` | Skip all prompts (isolated only) |

### Permission Rules

```json
{
  "permissions": {
    "allow": [
      "Bash",                      // All bash
      "Bash(npm run *)",           // Prefix match
      "Bash(git * main)",          // Wildcard
      "Read(src/**/*.ts)",         // File paths
      "WebFetch(domain:github.com)" // Domains
    ],
    "deny": [
      "Bash(rm -rf *)"
    ]
  }
}
```

### Bash Permission Examples

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run build)",
      "Bash(npm run test)",
      "Bash(git commit *)",
      "Bash(git push * main)",
      "Bash(curl http://*)",
      "Bash(* --version)"
    ]
  }
}
```

### File Path Rules

```json
{
  "permissions": {
    "allow": [
      "Read(src/**/*.ts)",         // All TS in src/
      "Read(~/.zshrc)",            // Home directory
      "Edit(/docs/**/*.md)"        // Project docs
    ],
    "deny": [
      "Read(./.env)",              // Block env files
      "Edit(//root/.ssh/**)"       // Absolute paths
    ]
  }
}
```

### Evaluation Order

1. **Deny** (block immediately)
2. **Ask** (prompt for confirmation)
3. **Allow** (auto-approve)

---

## Skills

### What are Skills?

Reusable workflows loaded on-demand. Unlike CLAUDE.md which loads at startup.

### Skill Locations

| Location | Scope |
|----------|-------|
| `~/.claude/skills/<name>/SKILL.md` | User (all projects) |
| `.claude/skills/<name>/SKILL.md` | Project |
| Plugin | Where plugin enabled |

### Creating a Skill

Directory structure:
```
~/.claude/skills/my-skill/
├── SKILL.md        # Required
├── template.md     # Optional
└── scripts/
    └── helper.sh   # Optional
```

Example SKILL.md:
```yaml
---
name: commit-message
description: Generate commit message from staged changes
disable-model-invocation: false
allowed-tools: "Bash(git diff *) Bash(git status *)"
---

## Staged Changes

!`git diff --cached`

## Task

Write a commit message using conventional commits format:
- Type: feat, fix, docs, etc.
- Keep first line <50 chars
- Include description
```

### Skill Frontmatter

```yaml
---
name: skill-name                 # Display name
description: What it does        # When to use
arguments: [arg1, arg2]         # Named arguments
disable-model-invocation: false # Claude can invoke
user-invocable: true            # Show in / menu
allowed-tools: "Read Edit Bash" # Pre-approve tools
model: opus                      # Override model
effort: high                     # Override effort
context: fork                    # Run in subagent
paths:                           # Load when editing
  - "src/api/**/*.ts"
---
```

### Dynamic Context Injection

Run commands before skill content is sent:

```yaml
---
name: pr-summary
---

## PR

Title: !`gh pr view --json title -q .title`

## Changes

```!
gh pr diff
```

Summarize above changes...
```

### String Substitutions

```yaml
---
arguments: [env, version]
---

Deploy to $env version $version

Position 0: $0
All args: $ARGUMENTS
Session: ${CLAUDE_SESSION_ID}
Skill dir: ${CLAUDE_SKILL_DIR}
```

---

## Models & Effort Levels

### Model Aliases

| Alias | Model | Best For |
|-------|-------|----------|
| `default` | Tier default | System default |
| `best` | opus | Most capable |
| `opus` | Opus 4.7 | Complex reasoning |
| `sonnet` | Sonnet 4.6 | Daily coding |
| `haiku` | Haiku 4.5 | Fast tasks |
| `opusplan` | Opus→Sonnet | Plan→execute |
| `opus[1m]` | Opus 1M context | Large projects |
| `sonnet[1m]` | Sonnet 1M | Large codebases |

### Setting Model

```bash
/model opus          # Switch in session
/model               # Open picker
claude --model opus  # At startup
export ANTHROPIC_MODEL="opus"  # Environment
```

### Effort Levels

| Level | Use Case | Cost |
|-------|----------|------|
| `low` | Quick tasks | Low |
| `medium` | Balanced | Medium |
| `high` | Default coding | High |
| `xhigh` | Deep reasoning (Opus 4.7) | Very high |
| `max` | Maximum (current session) | Unlimited |

### Setting Effort

```bash
/effort high         # Set in session
/effort              # Interactive slider
claude --effort xhigh # At startup
```

### One-off Deep Reasoning

Include `ultrathink` in prompt for extra thinking on that turn only.

### Extended Thinking

Claude's internal reasoning process.

```bash
Option+T / Alt+T     # Toggle for session
/config              # Set as default
Ctrl+O               # Show thinking (verbose)
```

### Extended Context (1M)

Available for Opus 4.7, Opus 4.6, Sonnet 4.6.

```bash
/model opus[1m]
/model sonnet[1m]
```

Automatic for Max/Team/Enterprise. Paid extra for Pro/API users.

---

## IDE Integrations

### VS Code Extension

**Install**:
- Marketplace: Search "Claude Code"
- Cmd+Shift+P → "Claude Code: Open"

**Key features**:
- Prompt in sidebar
- File/folder context
- Resume conversations
- Terminal mode

**Shortcuts**:
- `Cmd+Esc` - Toggle Claude Code
- `Cmd+Shift+L` - Add file to context

### JetBrains Plugin

**Install**:
- IDE Settings → Plugins → Marketplace → "Claude Code"
- Tools → Claude Code

**Features**:
- Integrated sidebar
- File context
- Terminal integration
- WSL support

---

## Advanced Features

### Non-Interactive Mode (Headless)

```bash
# Basic
claude -p "prompt"

# With output format
claude -p "task" --output-format json | jq '.result'

# Structured output
claude -p "Extract functions" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}}}'

# Streaming
claude -p "Explain" --output-format stream-json --verbose

# Continue
claude -p "First task"
claude -p "Continue" --continue

# Pre-approve tools
claude -p "Fix bugs" --allowedTools "Read,Edit,Bash"

# Bare mode (skip discovery)
claude --bare -p "Summarize" --allowedTools "Read"
```

### Worktree Isolation

Run parallel sessions with isolated auto memory:

```bash
git worktree add -b feature/auth ../feature-auth
cd ../feature-auth
claude              # Separate session, separate memory

# Clean up
git worktree remove ../feature-auth
```

### Sandboxing

OS-level isolation for Bash commands:

```json
{
  "sandbox": {
    "enabled": true,
    "filesystem": {
      "allowWrite": ["/tmp", "~/output"],
      "denyRead": ["~/.ssh"]
    },
    "network": {
      "allowedDomains": ["github.com"],
      "deniedDomains": ["malicious.com"]
    }
  }
}
```

### Subagents

Spawn isolated agents for specific tasks:

Built-in: `Explore`, `Plan`, `general-purpose`

File: `.claude/agents/my-agent.md`
```yaml
---
name: code-reviewer
model: opus
tools: Read Grep
---

Review this code change...
```

### Voice Dictation

```bash
/voice                      # Enable
Space (hold)               # Record
# Rebind in keybindings.json
```

### Loops & Scheduled Tasks

```bash
/loop 5m /check-tests      # Every 5 minutes
/loop                      # Let Claude decide interval
/schedule create --name daily --cron "0 9 * * *"
```

### Fast Mode

Lower token usage for less critical tasks:

```bash
Meta+O                     # Toggle
/fast                      # Toggle
```

### Fullscreen Mode

Immersive conversation view:

```json
{
  "tui": "fullscreen"
}
```

### Vim Mode

Edit with vim keybindings:

```bash
/vim
```

Or in settings:
```json
{
  "editorMode": "vim"
}
```

---

## Environment Variables

```bash
# Authentication
ANTHROPIC_API_KEY="sk-..."
ANTHROPIC_ORG_ID="org-..."
ANTHROPIC_BASE_URL="https://api.anthropic.com/v1"

# Models
ANTHROPIC_MODEL="opus"
ANTHROPIC_DEFAULT_OPUS_MODEL="claude-opus-4-7"
ANTHROPIC_DEFAULT_SONNET_MODEL="claude-sonnet-4-6"
ANTHROPIC_DEFAULT_HAIKU_MODEL="claude-haiku-4-5"
CLAUDE_CODE_SUBAGENT_MODEL="claude-sonnet-4-6"

# Effort & Thinking
CLAUDE_CODE_EFFORT_LEVEL="high"
MAX_THINKING_TOKENS=10000
CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=0

# Features
CLAUDE_CODE_DISABLE_1M_CONTEXT=0
CLAUDE_CODE_DISABLE_AUTO_MEMORY=0
DISABLE_PROMPT_CACHING=0

# Updates
DISABLE_AUTOUPDATER="1"
DISABLE_UPDATES="1"

# Tools
CLAUDE_CODE_USE_POWERSHELL_TOOL="1"
USE_BUILTIN_RIPGREP="1"

# Telemetry
CLAUDE_CODE_ENABLE_TELEMETRY="1"
```

---

## Quick Reference

**Start & Exit**:
```bash
claude                  # Interactive
claude -p "prompt"     # Non-interactive
Ctrl+D                 # Exit
```

**Models**:
```bash
/model opus           # Switch
/effort high          # Set effort
```

**Memory**:
```bash
/memory               # Browse memory
/init                 # Initialize CLAUDE.md
```

**Tools**:
```bash
/mcp                  # MCP servers
/plugins              # Plugins
/skills               # Skills
```

**Review**:
```bash
/review               # Local review
/security-review      # Security audit
```

**Utility**:
```bash
/help                 # Commands
/clear                # Clear chat
/compact              # Compress context
/status               # Info & usage
/doctor               # Diagnostics
```

---

**Last Updated**: May 8, 2026 | Claude Code v2.1.128+

For official docs: https://code.claude.com/docs

