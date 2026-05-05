# Bashly Modernization Design

**Date:** 2026-05-05
**Project:** os-scripts (`gt` CLI)
**Status:** Approved (pending user review of written spec)

## Goal

Upgrade the `gt` CLI codebase to leverage modern Bashly features for maintainability, DX, and reliability. Scope = framework-level improvements; functional roadmap items (Stages 3+ in `ROADMAPS.md`) remain out of scope.

## Motivation

`src/bashly.yml` has grown to ~750 lines, of which ~500 lines are duplication of identical `--version` / `--force` flag definitions across ~50 install and ~50 uninstall subcommands. This blocks adding tools quickly and obscures the few commands that have real shape (`install multi`, `setup antidote`, `setup starship`, `outdated`). The CLI also lacks shell completions, declared dependencies/env vars, and any test harness — all of which Bashly provides natively.

## Non-Goals

- Stage 3 reliability features (checksum, retries, atomic install, dry-run) — separate spec.
- Stage 4 state tracking (`~/.local/share/gt/state.json`, `gt list`, `gt pin`) — needs JSON, not Bashly's INI `config` helper. Separate spec.
- Switching `env: development` → `production`. Defer to release time.
- Migrating `plugins/zsh-*` layout (already done in prior work).

## Decisions

| Area | Decision | Rationale |
|---|---|---|
| DRY strategy | YAML anchors + `import:` split | No build step; explicit; native to Bashly |
| `strict: true` | **Defer** until tests are in place | Risk of latent bugs in install scripts; need tests to catch regressions safely |
| `env: production` | Keep `development` | Easier debug; no shipping pressure |
| `bashly add config` | **Skip** | Stage 4 needs JSON, not INI |
| Completions | `bashly add comp_function` (built-in `gt completions zsh`) | No extra file to ship |
| Test harness | `bashly add test` + Bats, no-network scope | Cover resolver, version_helpers, build smoke |

## Architecture

### File layout after refactor

```
src/
├── bashly.yml            # ~30 lines: name, version, env vars, footer, root deps, imports
└── commands/
    ├── install.yml       # ~180 lines: anchors + ~50 tools
    ├── uninstall.yml     # ~60 lines: anchors + ~50 tools
    ├── setup.yml         # ~50 lines
    └── outdated.yml      # ~10 lines
```

**Estimated total:** ~330 lines (down from 750, >50% reduction).

### YAML anchor pattern

```yaml
# commands/install.yml
x-anchors:
  std_install_flags: &std_install_flags
    - long: --version
      short: -v
      arg: version
      help: "Version to install (e.g., latest)"
      default: latest
    - long: --force
      short: -f
      help: "Force overwrite if already installed"

name: install
help: Install tools and components
commands:
  - name: kustomize
    help: Install Kustomize
    flags: *std_install_flags
    dependencies: [unzip]   # only for tools using zip archives

  - name: k9s
    help: Install k9s
    flags: *std_install_flags
  # ... ~44 simple tools using *std_install_flags
```

### Special-case tools (kept explicit)

`bashly`, `claude`, `gem`, `skopeo`, `tmux`, `rsync` — have `dependencies:` declarations or skip `--version`. They list flags explicitly rather than reusing the anchor.

### Root-level metadata (`src/bashly.yml`)

```yaml
name: gt
help: OS Scripts CLI — Install & manage DevOps tools
version: 0.1.0

environment_variables:
  - name: GITHUB_TOKEN
    help: "GitHub API token (raises rate limit 60→5000 req/hr for `gt outdated`)"
  - name: GT_DOWNLOAD_TIMEOUT
    help: "Override curl download timeout in seconds (default 30)"

footer: |
  Repo:    https://github.com/ttungbmt/os-scripts
  Roadmap: see ROADMAPS.md

dependencies:
  - curl
  - tar
```

`unzip` declared per-tool (only tools with `.zip` archives).

### Examples

Add `examples:` only on commands where flags don't self-explain:
- Root: `gt install kubectl`, `gt install multi kubectl k9s argocd`, `gt outdated --all`
- `install multi` — comma vs space syntax
- `setup multi`, `setup antidote`, `setup starship --preset tokyo-night`

Skip examples on individual `install <tool>` entries.

### Completions

`bashly add comp_function` adds `gt completions <shell>` subcommand. User wires up:

```zsh
# ~/.zshrc
source <(gt completions zsh)
```

Suggests all 50 tool names for `gt install <TAB>`, `gt uninstall <TAB>`, `gt outdated <TAB>`.

### Test harness

`bashly add test` + `bashly add bats3`. Folder: `test/` (Bashly default; rename existing empty `tests/` if present).

**In scope:**

| Layer | What |
|---|---|
| bashly build smoke | `bashly generate` succeeds; `bash -n gt`; `gt --help`, `gt install --help` produce expected sections (approval-style) |
| registry resolver | Source 1 registry, assert `TOOL_*` vars set; template `${VERSION}/${DETECT_OS}/${DETECT_ARCH}` substitute correctly |
| version_helpers | `_default_fetch_local_version`; hyphen tool name (`kube-linter`) resolution |
| generic_install logic | `_install_from_extracted_dir` with binary-in-subdir fixture, chmod, move |

**Out of scope:** real downloads, real `/usr/local/bin` writes, `setup antidote/starship` (touches user dotfiles).

**Fixtures:** `test/fixtures/` — fake `.tar.gz` containing trivial echo binaries; fake registry files.

**Run:** `bats test/` (or `./test/run` if Bashly emits one).

## Migration / Rollout

Each step ships in its own PR; each is independently verifiable.

| # | Step | Verify |
|---|---|---|
| 1 | Split `bashly.yml` → 4 imports under `commands/`. Anchors not yet introduced. | `bashly generate`; `diff gt gt.bak` byte-identical |
| 2 | Add anchors; convert ~44 simple tools to `*std_install_flags`. | `diff gt gt.bak` byte-identical |
| 3 | Add `environment_variables`, `footer`, root `dependencies: [curl, tar]`, per-tool `dependencies: [unzip]`. | `gt --help` shows env vars + footer |
| 4 | Add `examples:` on ~6 complex commands. | `gt install --help` shows examples |
| 5 | `bashly add comp_function`; verify `source <(gt completions zsh)` enables `<TAB>` completion. | Manual zsh test |
| 6 | `bashly add test`; write resolver + version_helpers + build-smoke tests. | `bats test/` green |
| 7 | (Defer) Set `strict: true`; fix any latent bugs surfaced. | `bats test/` + manual install of 5 tools (binary, tar.gz, zip, pip, dependency-using) |

**Mitigation for Step 1:** Keep `bashly.yml.bak` until Step 1 generates byte-identical output and is merged.

## Risks

1. **Step 1 import failure**: malformed split breaks CLI. Mitigated by byte-diff verification + backup.
2. **Step 7 strict mode bugs**: latent unbound-var or pipefail issues in registry/install scripts. Mitigated by Step 6 tests covering core paths first.
3. **Anchor incompatibility for special tools**: 6 tools list flags explicitly to avoid forcing the anchor pattern. Acceptable cost (~30 lines extra).

## Success Criteria

- `bashly.yml` + imports total ≤ 400 lines.
- `bats test/` green covering resolver, version_helpers, build-smoke (≥4 test files).
- `gt completions zsh` produces working zsh completion script.
- `gt --help` shows declared env vars and footer.
- Adding a new simple tool requires editing only `commands/install.yml` + `commands/uninstall.yml` (~5 lines total) + 1 registry file.
