# npm → mise Install Type Migration Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Migrate tools installed via `npm -g` to use `mise` as the install backend, adding a reusable `mise` INSTALL_TYPE to the generic install/uninstall engine.

**Architecture:** Add `mise` as a first-class INSTALL_TYPE in `generic_install.sh` and `generic_uninstall.sh` using the pattern `mise use -g npm:<package>[@version]`. Replace claude's custom npm install/uninstall scripts with the generic engine. Registry variable `TOOL_MISE_PKG` declares the package (e.g. `npm:@anthropic-ai/claude-code`).

**Tech Stack:** Bash, mise (jdx/mise), BATS for testing.

---

## Context

Currently affected tools (npm INSTALL_TYPE):

| Tool | Registry | Package |
|------|----------|---------|
| claude | `src/lib/registry/claude.sh` | `@anthropic-ai/claude-code` |

The generic engine (`src/lib/generic_install.sh`) handles `github_release` and `pip` but has **no `npm` handler** — claude uses custom scripts. This plan replaces those with a generic `mise` handler so future npm tools follow the same pattern.

**Why mise instead of bare npm?**
- `mise` manages Node.js versions independently (no global Node required system-wide)
- Tools stay version-pinned and isolated
- Consistent with the antidote zsh plugin stack (`plugins/mise` is already loaded)

---

## Task 1: Add `mise` INSTALL_TYPE to generic install engine

**Files:**
- Modify: `src/lib/generic_install.sh` (after line 173, inside `run_generic_install`)
- Test: `tests/generic_install.bats`

**Step 1: Write the failing test**

Add to `tests/generic_install.bats`:

```bash
@test "run_generic_install with mise type calls 'mise use -g' with package" {
  # Stub mise
  mise() { echo "mise $*"; }
  export -f mise

  FAKE_INSTALL_TYPE="mise"
  FAKE_MISE_PKG="npm:fake-tool"

  run run_generic_install "fake" "latest" ""
  [ "$status" -eq 0 ]
  [[ "$output" == *"mise use -g npm:fake-tool"* ]]
}
```

**Step 2: Run to verify it fails**

```bash
cd /home/ubuntu/workspace/devops/kube-gtelots/os-scripts
docker compose run --rm test bats tests/generic_install.bats
```
Expected: FAIL — no mise branch in `run_generic_install`

**Step 3: Add mise handler to `src/lib/generic_install.sh`**

Insert after the `elif [[ "$install_type" == "pip" ]]` block (before the closing `fi` on line 173):

```bash
  elif [[ "$install_type" == "mise" ]]; then
    local mise_pkg_var="${tool_upper}_MISE_PKG"
    local mise_pkg="${!mise_pkg_var}"

    if [[ -z "$mise_pkg" ]]; then
      echo "$(red "Error: MISE_PKG not defined for $name")"
      exit 1
    fi

    if ! command -v mise >/dev/null 2>&1; then
      echo "$(red "Error: mise is not installed. Run: gc install mise")"
      exit 1
    fi

    # Guard against overwrite (check if tool binary already exists)
    local tool_bin
    tool_bin=$(command -v "$name" 2>/dev/null || true)
    if [[ -n "$tool_bin" && -z "$force" ]]; then
      echo "$(red "Error:") $name is already installed at $tool_bin."
      echo "Use $(bold "--force") (or $(bold "-f")) to overwrite."
      exit 1
    fi

    local mise_install_pkg="$mise_pkg"
    if [[ "$version" != "latest" ]]; then
      local dl_version="${version#v}"
      mise_install_pkg="${mise_pkg}@${dl_version}"
    fi

    echo "Installing $(cyan_bold "$name") via mise (${mise_install_pkg})..."
    if mise use -g "$mise_install_pkg"; then
      echo "$(green_bold ✓) $name installed successfully via mise."
    else
      echo "$(red ✗ Failed to install $name.)"
      exit 1
    fi
```

**Step 4: Run test to verify it passes**

```bash
docker compose run --rm test bats tests/generic_install.bats
```
Expected: PASS

**Step 5: Commit**

```bash
git add src/lib/generic_install.sh tests/generic_install.bats
git commit -m "feat: add mise INSTALL_TYPE to generic install engine"
```

---

## Task 2: Add `mise` uninstall handler to generic uninstall engine

**Files:**
- Modify: `src/lib/generic_uninstall.sh`

**Step 1: Write the failing test**

Add to a new or existing uninstall test file (if none exists, add to `tests/generic_install.bats`):

```bash
@test "run_generic_uninstall with mise type calls 'mise uninstall'" {
  mise() { echo "mise $*"; }
  export -f mise

  FAKE_INSTALL_TYPE="mise"
  FAKE_MISE_PKG="npm:fake-tool"

  # fake 'fake' is installed
  fake() { :; }
  export -f fake

  run run_generic_uninstall "fake"
  [ "$status" -eq 0 ]
  [[ "$output" == *"mise uninstall npm:fake-tool"* ]]
}
```

**Step 2: Run to verify it fails**

```bash
docker compose run --rm test bats tests/generic_install.bats
```

**Step 3: Add mise uninstall handler to `src/lib/generic_uninstall.sh`**

Insert after the `if [[ "$install_type" == "pip" ]]` block (before the `else`):

```bash
  elif [[ "$install_type" == "mise" ]]; then
    local mise_pkg_var="${tool_upper}_MISE_PKG"
    local mise_pkg="${!mise_pkg_var}"

    if ! command -v "$name" >/dev/null 2>&1; then
      echo "$(cyan_bold "$name") is not installed."
      exit 0
    fi

    echo "Uninstalling $(cyan_bold "$name") via mise..."
    if mise uninstall "$mise_pkg"; then
      echo "$(green_bold ✓) $name uninstalled successfully."
    else
      echo "$(red ✗ Failed to uninstall $name.)"
      exit 1
    fi
```

**Step 4: Run test to verify it passes**

```bash
docker compose run --rm test bats tests/generic_install.bats
```

**Step 5: Commit**

```bash
git add src/lib/generic_uninstall.sh tests/generic_install.bats
git commit -m "feat: add mise uninstall handler to generic uninstall engine"
```

---

## Task 3: Migrate claude registry from npm → mise

**Files:**
- Modify: `src/lib/registry/claude.sh`

**Step 1: Update registry variables**

Replace content of `src/lib/registry/claude.sh`:

```bash
CLAUDE_INSTALL_TYPE="mise"
CLAUDE_MISE_PKG="npm:@anthropic-ai/claude-code"

claude_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null | awk '{print $1}'
}

claude_fetch_remote_version() {
  mise latest npm:@anthropic-ai/claude-code 2>/dev/null
}
```

**Step 2: Verify registry resolves correctly**

```bash
docker compose run --rm test bats tests/registry_resolver.bats
```
Expected: PASS (existing tests should still pass)

**Step 3: Commit**

```bash
git add src/lib/registry/claude.sh
git commit -m "feat: migrate claude registry from npm to mise install type"
```

---

## Task 4: Remove custom claude install/uninstall scripts

**Files:**
- Delete: `src/commands/install/claude.sh`
- Delete: `src/commands/uninstall/claude.sh`

> These scripts bypass the generic engine. After Task 1-3, the generic engine handles mise-type tools, so these are no longer needed.

**Step 1: Check if any other code references these scripts**

```bash
grep -r "install/claude\|uninstall/claude" /home/ubuntu/workspace/devops/kube-gtelots/os-scripts/src --include="*.yml"
```
Expected: no critical references (bashly routes by filename, not content)

**Step 2: Check bashly.yml to confirm routing**

```bash
grep -A5 "name: claude" /home/ubuntu/workspace/devops/kube-gtelots/os-scripts/src/commands/install.yml
grep -A5 "name: claude" /home/ubuntu/workspace/devops/kube-gtelots/os-scripts/src/commands/uninstall.yml
```

If the yml references `root: src/commands/install/claude.sh`, that means it currently bypasses generic. After deleting, the install.yml must route to the generic handler instead.

**Step 3: Update install.yml to use generic handler for claude**

Check how other tools that use generic are configured in `install.yml` — they should NOT have a tool-specific `root:` path but instead fall through to the generic handler. Update accordingly.

**Step 4: Delete the custom scripts**

```bash
rm src/commands/install/claude.sh
rm src/commands/uninstall/claude.sh
```

**Step 5: Rebuild CLI**

```bash
bashly generate
```

**Step 6: Smoke test**

```bash
docker compose run --rm test bats tests/build_smoke.bats
```
Expected: PASS

**Step 7: Commit**

```bash
git add -A
git commit -m "refactor: remove custom claude install/uninstall scripts, use generic mise handler"
```

---

## Task 5: Add version fetch test for mise remote version

**Files:**
- Modify: `tests/version_helpers.bats` or `tests/registry_resolver.bats`

**Step 1: Write test**

```bash
@test "claude_fetch_remote_version uses mise latest" {
  source "${GT_PROJECT_ROOT}/src/lib/registry/claude.sh"

  # Stub mise
  mise() { echo "1.2.3"; }
  export -f mise

  run claude_fetch_remote_version
  [ "$status" -eq 0 ]
  [ "$output" = "1.2.3" ]
}
```

**Step 2: Run test**

```bash
docker compose run --rm test bats tests/version_helpers.bats
```

**Step 3: Commit**

```bash
git add tests/version_helpers.bats
git commit -m "test: add claude_fetch_remote_version test for mise backend"
```

---

## Verification

```bash
# Full test suite
docker compose run --rm test

# Manual smoke test (on a machine with mise installed)
gc install claude
claude --version
gc uninstall claude
```

---

## Future npm tools

To add a new npm-installed tool (e.g. `foo` from `npm:@scope/foo`), follow this pattern:

**Registry `src/lib/registry/foo.sh`:**
```bash
FOO_INSTALL_TYPE="mise"
FOO_MISE_PKG="npm:@scope/foo"

foo_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null
}

foo_fetch_remote_version() {
  mise latest npm:@scope/foo 2>/dev/null
}
```

No custom install/uninstall scripts needed — the generic engine handles it.
