---
name: install-tool
description: |
  Add install & uninstall commands for a new CLI tool to the os-scripts Bashly project.
  Use when users ask to add a new tool (e.g., "install helm", "add sops support",
  "viết install fastfetch"). This skill enforces DRY patterns using shared helpers
  in `src/lib/install_helpers.sh`.
---

# Install Tool Skill

Use this workflow to add `./gt install <tool>` and `./gt uninstall <tool>` commands.

## Prerequisites

Before starting, confirm these files exist in the project:

- `src/bashly.yml` — CLI command definitions
- `src/lib/install_helpers.sh` — Shared helper functions (install, uninstall, download, guard)
- `src/lib/setup_helpers.sh` — Shared setup helpers (inject_config_block, seed_file)
- `src/lib/version_helpers.sh` — Core engine for checking versions
- `src/lib/registry/` — Directory containing individual tool version profiles
- `src/lib/colors.sh` — Color output functions
- `settings.yml` — Bashly settings with `commands_dir: commands`

## Workflow

### 1. Research installation methods

Before writing any code, determine **which installation method** to use. Investigate the tool's
official documentation, GitHub releases page, and package availability.

#### Installation method priority (highest → lowest)

| Priority | Method | When to use | Install target | Uninstall method |
|---|---|---|---|---|
| **1st** | GitHub Release binary | Tool publishes pre-built binaries or archives on GitHub Releases | `/usr/local/bin/<tool>` | `uninstall_tool` |
| **2nd** | Git clone | Tool is a shell plugin/framework with no compiled binary (e.g., antidote, oh-my-zsh) | `/usr/local/share/<tool>` | `remove_git_repo` |
| **3rd** | OS package manager | Tool has no GitHub release and is only available via `apt`/`dnf`/`pacman` (e.g., zsh, git) | System-managed | `remove_package` |
| **4th** | Language package manager | Tool is a Python/Node/etc. package with no binary release (e.g., thefuck via pip) | System-managed | Language-specific uninstall |

**Rationale for this order:**
- **Binary first**: Single file → `cp` to install, `rm` to uninstall, `scp` to move to another
  server. Full control over version pinning. Works identically on any Linux distro. No dependency
  on distro package freshness or language runtimes. Most DevOps/Cloud-native tools publish
  static binaries — always check GitHub Releases first.
- **Git clone second**: For tools that ARE source code (shell plugins/frameworks) with no
  compiled binary. Still portable and version-pinnable via `--branch <tag>`.
- **Package manager third**: Version lags behind upstream, varies across distros. Only use when
  the tool genuinely has no binary release (e.g., `zsh`, `git`, system utilities).
- **Language pkg last**: Requires the language runtime (Python/Node/etc.) as a dependency layer.
  Only use when the tool is exclusively distributed as a language package (e.g., `thefuck` via pip).

#### Decision tree

Use this flowchart to determine the correct installation method:

```
Does the tool publish pre-built binaries on GitHub Releases?
├── YES → Method 1 (GitHub Release binary)
│         ├── Archive (.tar.gz / .zip) → download + extract + install_binary
│         └── Bare binary (no archive) → download + install_binary
└── NO
    ├── Is the tool a shell plugin/framework (pure .sh/.zsh files)?
    │   ├── YES → Method 2 (Git clone)
    │   └── NO
    │       ├── Is the tool available via OS package manager (apt/dnf)?
    │       │   ├── YES → Method 3 (OS package manager)
    │       │   └── NO
    │       │       └── Is it a pip/npm/cargo package?
    │       │           ├── YES → Method 4 (Language package manager)
    │       │           └── NO → Custom solution needed (document in script)
    │       └──
    └──
```

#### Research checklist

For **GitHub Release binary** (Priority 1):
- **GitHub repo** (e.g., `derailed/k9s`): Needed for `github_latest_tag` helper.
- **Release asset naming convention**: Check the GitHub Releases page to understand the
  exact filename pattern. Pay attention to:
  - OS naming: lowercase (`linux`) vs capitalized (`Linux`)
  - Architecture naming: `amd64` vs `x86_64`, `arm64` vs `aarch64`
  - Archive format: `.tar.gz`, `.zip`, or bare binary
  - Whether the version in the URL includes `v` prefix or not
- **Non-GitHub download URLs**: Some tools have their own download endpoints (e.g., kubectl uses
  `dl.k8s.io`, vault uses `releases.hashicorp.com`). Identify the correct URL pattern.
- **Use `scripts/fetch_assets.py`**: Add the tool's repo to the script and run it to discover
  the exact asset naming pattern automatically.

For **Git clone** (Priority 2):
- **GitHub repo**: Needed for `install_git_repo` helper.
- **Tag format**: Check if the tool uses tags like `v1.9.7` for versioning.
- **Key file**: Identify the main entry point file (e.g., `antidote.zsh`) to use for
  `require_installed` checks in setup commands.

For **OS package manager** (Priority 3):
- **Package name**: May differ from the tool name (e.g., package `zsh` for tool `zsh`).
- **Distro availability**: Verify the package exists in `apt`, `dnf`, `pacman`, `apk`.

For **Language package manager** (Priority 4):
- **Package name**: e.g., PyPI package `thefuck`.
- **Remote version API**: e.g., `https://pypi.org/pypi/<pkg>/json` for PyPI.

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

Choose the pattern that matches the tool's installation method (see priority table in Step 1).

#### Method 1: GitHub Release binary (preferred)

Write `src/commands/install/<tool-name>.sh`:

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

**Variations for Method 1:**

Bare binary download (no archive) — e.g., kubectl, argocd:
```bash
temp_dir=$(mktemp -d)
download_file "$download_url" "$temp_dir/<tool>"
install_binary "$temp_dir/<tool>" "$target"
rm -rf "$temp_dir"
echo "$(green_bold ✓) $name installed successfully: $(bold "$version")"
```

Tool with its own install script — e.g., kustomize:
```bash
curl -s "<install-script-url>" \
  | sed 's/curl -sLO/curl -#LO/' \
  | bash -s -- "$temp_dir" > /dev/null
```

#### Method 2: Git clone — e.g., antidote

```bash
version=${args[--version]}
force=${args[--force]}
name="<tool-name>"
repo_url="https://github.com/<owner>/<repo>.git"
target="/usr/local/share/<tool-name>"

# Guard: check if directory already exists
if [ -d "$target" ] && [ -z "$force" ]; then
  echo "$(red Error:) ${name} is already installed at ${target}."
  echo "Use $(bold --force) (or $(bold -f)) to update/overwrite."
  exit 1
fi

echo "Installing $(cyan_bold "$name")..."

# Resolve version
if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "<owner>/<repo>")
fi

# Clone or update
if install_git_repo "$repo_url" "$target" "$version"; then
  echo "$(green_bold ✓) $name installed successfully at $target."
else
  echo "$(red ✗ Failed to install $name.)"
  exit 1
fi
```

#### Method 3: OS package manager — e.g., zsh

```bash
version=${args[--version]}
force=${args[--force]}
name="<tool-name>"

# Guard
if command -v <tool-name> >/dev/null 2>&1 && [ -z "$force" ]; then
  echo "$(red Error:) ${name} is already installed at $(command -v <tool-name>)."
  echo "Use $(bold --force) (or $(bold -f)) to overwrite/reinstall."
  exit 1
fi

echo "Installing $(cyan_bold "$name") via package manager..."

if install_package "$name"; then
  echo "$(green_bold ✓) $name installed successfully."
else
  echo "$(red ✗ Failed to install $name.)"
  exit 1
fi
```

#### Method 4: Language package manager — e.g., thefuck (pip)

```bash
version=${args[--version]}
force=${args[--force]}
name="<tool-name>"
target="/usr/local/bin/<tool-name>"

guard_existing "$name" "$target" "$force"

echo "Installing $(cyan_bold "$name") via pip..."

if pip3 install --break-system-packages <pip-package-name>; then
  echo "$(green_bold ✓) $name installed successfully."
else
  echo "$(red ✗ Failed to install $name.)"
  exit 1
fi
```

### 5. Implement the uninstall script

Write `src/commands/uninstall/<tool-name>.sh` — match the method used for install:

**Method 1 (Binary):**
```bash
uninstall_tool "<tool-name>" "/usr/local/bin/<tool-name>"
```

**Method 2 (Git clone):**
```bash
name="<tool-name>"
target="/usr/local/share/<tool-name>"

if [ ! -d "$target" ]; then
  echo "$(yellow ${name} is not installed) at ${target}."
  exit 0
fi

echo -n "Are you sure you want to uninstall $(cyan_bold "${name}") at $target? [y/N] "
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

echo "Uninstalling $(cyan_bold "${name}")..."
remove_git_repo "$target"

if [ ! -d "$target" ]; then
  echo "$(green_bold ✓) ${name} uninstalled successfully."
else
  echo "$(red ✗ Failed to uninstall ${name}.)"
  exit 1
fi
```

**Method 3 (Package manager):**
```bash
name="<tool-name>"

if ! command -v <tool-name> >/dev/null 2>&1; then
  echo "$(yellow ${name} is not installed.)"
  exit 0
fi

echo -n "Are you sure you want to uninstall $(cyan_bold "${name}")? [y/N] "
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

remove_package "$name"
echo "$(green_bold ✓) ${name} uninstalled."
```

### 6. Create registry file for versioning

Create `src/lib/registry/<tool-name>.sh` to allow the `./gt outdated` command to detect and check this tool's version.

**Method 1 — GitHub Release binary:**
```bash
<TOOL_NAME>_GITHUB_REPO="<owner>/<repo>"

<tool-name>_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | awk '{print $2}'
}
```

**Method 2 — Git clone:**
```bash
<TOOL_NAME>_GITHUB_REPO="<owner>/<repo>"

<tool-name>_fetch_local_version() {
  local target="$1"
  local repo_dir
  repo_dir=$(dirname "$target")
  if [ -d "$repo_dir/.git" ]; then
    git -C "$repo_dir" describe --tags --abbrev=0 2>/dev/null | tr -d 'v\r\n'
  fi
}
```

**Method 3 — Package manager (no remote version tracking):**
```bash
<tool-name>_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | awk '{print $2}'
}

<tool-name>_fetch_remote_version() {
  # Package manager tools: return local version so they appear up-to-date
  if command -v <tool-name> >/dev/null 2>&1; then
    <tool-name> --version 2>/dev/null | awk '{print $2}'
  fi
}
```

**Method 4 — Language package manager:**
```bash
<TOOL_NAME>_INSTALL_TYPE="pip"
<TOOL_NAME>_PIP_PKG="<pip-package-name>"

<tool-name>_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | awk '{print $2}'
}

<tool-name>_fetch_remote_version() {
  curl -s "https://pypi.org/pypi/<pip-package-name>/json" | sed -n 's/.*"version":"\([^"]*\)".*/\1/p' | head -n 1
}
```

### 7. Generate and validate

```bash
bashly generate
./gt install <tool-name> --help
./gt uninstall <tool-name> --help
sudo ./gt install <tool-name>
```

## Available Helper Functions

All helpers are in `src/lib/install_helpers.sh` and `src/lib/setup_helpers.sh`. **Never duplicate this logic in command scripts.**

| Function | Purpose | Usage |
|---|---|---|
| `detect_platform` | Sets `DETECT_OS` (linux/darwin) and `DETECT_ARCH` (amd64/arm64) | `detect_platform` |
| `github_latest_tag` | Fetches latest release tag from GitHub API | `version=$(github_latest_tag "owner/repo")` |
| `guard_existing` | Blocks install if binary exists (unless `--force`) | `guard_existing "$name" "$target" "$force"` |
| `require_installed` | Blocks setup if tool is not installed | `require_installed "$name" "$target"` |
| `install_binary` | `chmod +x` + `mv` with auto-sudo | `install_binary "/tmp/tool" "/usr/local/bin/tool"` |
| `install_git_repo` | `git clone --depth=1` with auto-sudo | `install_git_repo "$url" "$dest" "$version"` |
| `install_package` | Install via OS package manager (apt/dnf/yum/pacman/apk) | `install_package "pkg_name"` |
| `remove_binary` | `rm -f` with auto-sudo | `remove_binary "/usr/local/bin/tool"` |
| `remove_git_repo` | `rm -rf` directory with auto-sudo | `remove_git_repo "/usr/local/share/tool"` |
| `remove_package` | Uninstall via OS package manager | `remove_package "pkg_name"` |
| `download_file` | `curl -#fL` with progress bar + error handling | `download_file "$url" "$dest"` |
| `uninstall_tool` | Complete uninstall flow (check → confirm → remove → verify) | `uninstall_tool "name" "/path"` |
| `inject_config_block` | Idempotent dotfile block injection (for setup commands) | `inject_config_block "$file" "$marker" "$content"` |
| `seed_file` | Write content to file if empty or missing (for setup commands) | `seed_file "$file" "$content"` |

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
- **Git clone target**: Always `/usr/local/share/<tool-name>`
- **bashly.yml command name**: Use the exact binary name (lowercase, hyphen-separated)
- **Install script**: `src/commands/install/<tool-name>.sh`
- **Uninstall script**: `src/commands/uninstall/<tool-name>.sh`
- **Registry file**: `src/lib/registry/<tool-name>.sh`
- **Template file**: `src/lib/templates/<tool-name>.sh` (only if the tool needs a `setup` command)
- **Variable names**: `version`, `force`, `name`, `target`, `download_url`, `temp_dir`

## Checklist

Before marking a tool as done:

- [ ] Installation method researched and priority order followed (binary > git > package > language pkg)
- [ ] `bashly.yml` has both `install` and `uninstall` entries
- [ ] Install script uses the correct method's pattern
- [ ] Uninstall script matches the install method
- [ ] Registry file `src/lib/registry/<tool-name>.sh` is created with local fetch logic
- [ ] No duplicated logic from `install_helpers.sh`
- [ ] `bashly generate` runs without errors
- [ ] `./gt install <tool> --help` shows correct flags
- [ ] Tested: fresh install, already-installed guard, `--force` override
