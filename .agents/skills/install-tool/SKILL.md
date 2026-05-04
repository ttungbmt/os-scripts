---
name: install-tool
description: |
  Add install & uninstall commands for a new CLI tool to the os-scripts Bashly project.
  Use when users ask to add a new tool (e.g., "install helm", "add sops support",
  "viết install fastfetch"). This skill enforces DRY patterns using shared helpers
  in `src/lib/install_helpers.sh`.
---

# Install Tool Skill

Use this workflow to add `./cli install <tool>` and `./cli uninstall <tool>` commands.

## Prerequisites

Before starting, confirm these files exist in the project:

- `src/bashly.yml` — CLI command definitions
- `src/lib/install_helpers.sh` — Shared helper functions
- `src/lib/colors.sh` — Color output functions
- `settings.yml` — Bashly settings with `commands_dir: commands`

## Workflow

### 1. Research the tool's release pattern

Before writing any code, determine:

- **GitHub repo** (e.g., `derailed/k9s`): Needed for `github_latest_tag` helper.
- **Release asset naming convention**: Check the GitHub Releases page to understand the
  exact filename pattern. Pay attention to:
  - OS naming: lowercase (`linux`) vs capitalized (`Linux`)
  - Architecture naming: `amd64` vs `x86_64`, `arm64` vs `aarch64`
  - Archive format: `.tar.gz`, `.zip`, or bare binary
  - Whether the version in the URL includes `v` prefix or not
- **Non-GitHub tools**: Some tools have their own download endpoints (e.g., kubectl uses
  `dl.k8s.io`, kustomize has its own install script). Identify the correct URL pattern.

### 2. Update `src/bashly.yml`

Add the new tool under **both** the `install` and `uninstall` command groups.

#### Install command template

```yaml
  - name: <tool-name>
    help: Install <tool-name>
    flags:
    - long: --version
      short: -v
      arg: version
      help: <tool-name> version to install (e.g., v1.0.0 or latest)
      default: latest
    - long: --force
      short: -f
      help: Force overwrite if <tool-name> is already installed
```

#### Uninstall command template

```yaml
  - name: <tool-name>
    help: Uninstall <tool-name>
```

### 3. Run `bashly generate` to scaffold files

```bash
bashly generate
```

This creates placeholder files at:
- `src/commands/install/<tool-name>.sh`
- `src/commands/uninstall/<tool-name>.sh`

### 4. Implement the install script

Write `src/commands/install/<tool-name>.sh` using this pattern:

```bash
version=${args[--version]}
force=${args[--force]}
name="<tool-name>"
target="/usr/local/bin/<tool-name>"

# --- Step 1: Guard against overwrite ---
guard_existing "$name" "$target" "$force"

echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

# --- Step 2: Resolve version ---
if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "<owner>/<repo>")
  # Or for non-GitHub tools:
  # version=$(curl -sL https://some-api/stable.txt)
fi

# Strip or add 'v' prefix as needed by the download URL
if [[ "$version" == v* ]]; then
  version="${version:1}"
fi

# --- Step 3: Detect platform ---
detect_platform

# --- Step 4: Build download URL ---
download_url="https://github.com/<owner>/<repo>/releases/download/v${version}/<tool>_${DETECT_OS}_${DETECT_ARCH}.tar.gz"

# --- Step 5: Download & extract ---
temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/<tool>.tar.gz"
tar -xzf "$temp_dir/<tool>.tar.gz" -C "$temp_dir" <tool-binary-name>

# --- Step 6: Install binary ---
if [ -f "$temp_dir/<tool-binary-name>" ]; then
  install_binary "$temp_dir/<tool-binary-name>" "$target"
  rm -rf "$temp_dir"
  echo "$(green_bold ✓) $name installed successfully: $(bold "v${version}")"
else
  echo "$(red ✗ Failed to install $name.)"
  rm -rf "$temp_dir"
  exit 1
fi
```

#### Variations

**Bare binary download (no archive)** — e.g., kubectl:
```bash
temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/<tool>"
install_binary "$temp_dir/<tool>" "$target"
rm -rf "$temp_dir"
echo "$(green_bold ✓) $name installed successfully: $(bold "$version")"
```

**Tool with its own install script** — e.g., kustomize:
```bash
curl -s "<install-script-url>" \
  | sed 's/curl -sLO/curl -#LO/' \
  | bash -s -- "$temp_dir" > /dev/null
```

### 5. Implement the uninstall script

Write `src/commands/uninstall/<tool-name>.sh` — this is always a single line:

```bash
uninstall_tool "<tool-name>" "/usr/local/bin/<tool-name>"
```

### 6. Generate and validate

```bash
bashly generate
./cli install <tool-name> --help
./cli uninstall <tool-name> --help
sudo ./cli install <tool-name>
```

## Available Helper Functions

All helpers are in `src/lib/install_helpers.sh`. **Never duplicate this logic in command scripts.**

| Function | Purpose | Usage |
|---|---|---|
| `detect_platform` | Sets `DETECT_OS` (linux/darwin) and `DETECT_ARCH` (amd64/arm64) | `detect_platform` |
| `github_latest_tag` | Fetches latest release tag from GitHub API | `version=$(github_latest_tag "owner/repo")` |
| `guard_existing` | Blocks install if binary exists (unless `--force`) | `guard_existing "$name" "$target" "$force"` |
| `install_binary` | `chmod +x` + `mv` with auto-sudo | `install_binary "/tmp/tool" "/usr/local/bin/tool"` |
| `remove_binary` | `rm -f` with auto-sudo | `remove_binary "/usr/local/bin/tool"` |
| `download_file` | `curl -#fL` with progress bar + error handling | `download_file "$url" "$dest"` |
| `uninstall_tool` | Complete uninstall flow (check → remove → verify) | `uninstall_tool "name" "/path"` |

## Color Functions

Available from `src/lib/colors.sh`. Use these for consistent output:

| Context | Function | Example |
|---|---|---|
| Tool name | `cyan_bold` | `$(cyan_bold "$name")` |
| Version string | `yellow` / `bold` | `$(yellow "$version")` |
| Success marker | `green_bold` | `$(green_bold ✓)` |
| Error messages | `red` | `$(red Error:)` |
| Flag references | `bold` | `$(bold --force)` |

## Naming Conventions

- **Binary target**: Always `/usr/local/bin/<tool-name>`
- **bashly.yml command name**: Use the exact binary name (lowercase, hyphen-separated)
- **Install script**: `src/commands/install/<tool-name>.sh`
- **Uninstall script**: `src/commands/uninstall/<tool-name>.sh`
- **Variable names**: `version`, `force`, `name`, `target`, `download_url`, `temp_dir`

## Checklist

Before marking a tool as done:

- [ ] `bashly.yml` has both `install` and `uninstall` entries
- [ ] Install script uses `guard_existing`, `detect_platform`, `download_file`, `install_binary`
- [ ] Uninstall script is a single `uninstall_tool` call
- [ ] No duplicated logic from `install_helpers.sh`
- [ ] `bashly generate` runs without errors
- [ ] `./cli install <tool> --help` shows correct flags
- [ ] Tested: fresh install, already-installed guard, `--force` override
