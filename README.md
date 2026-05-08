# os-scripts

CLI `gc` — cài đặt và quản lý DevOps tools trên Linux/macOS, xây dựng bằng [Bashly](https://bashly.dev).

## Cài đặt nhanh

```shell
# Build CLI từ source
docker compose run --rm shell bash
bashly generate

# Hoặc dùng binary đã build sẵn
./gc --help
```

## Commands

### `gc install <tool> [flags]`

Cài một tool. Mặc định lấy phiên bản `latest`.

```shell
gc install kubectl
gc install kubectl --version v1.30.0
gc install kubectl --force          # ghi đè nếu đã cài
```

### `gc install multi <tool1> <tool2> ...`

Cài nhiều tools cùng lúc.

```shell
gc install multi kubectl k9s argocd
gc install multi kubectl,k9s,argocd  # dùng dấu phẩy cũng được
gc install multi --force kubectl k9s
```

### `gc uninstall <tool>`

Gỡ cài đặt một tool.

```shell
gc uninstall kubectl
gc uninstall helm
```

### `gc setup <target> [flags]`

Cấu hình môi trường sau khi cài.

```shell
gc setup antidote            # cấu hình Zsh plugin manager
gc setup starship            # cấu hình prompt
gc setup starship --preset tokyo-night
gc setup claude              # seed ~/.claude/settings.json
gc setup multi zoxide mcfly  # cấu hình nhiều tools
```

### `gc outdated [tool] [--all]`

Kiểm tra phiên bản đã cũ.

```shell
gc outdated kubectl
gc outdated --all            # kiểm tra tất cả tools đã cài
```

### `gc completions [bash|zsh]`

Sinh shell completion script.

```shell
gc completions zsh >> ~/.zshrc
```

## Tools được hỗ trợ

### Kubernetes / GitOps

| Tool | Mô tả |
|------|-------|
| `kubectl` | Kubernetes CLI |
| `k9s` | Terminal UI cho Kubernetes |
| `helm` | Kubernetes package manager |
| `helmfile` | Declarative Helm releases |
| `argocd` | GitOps continuous delivery |
| `krew` | kubectl plugin manager |
| `ksops` | Kustomize + SOPS plugin |
| `kubeseal` | Sealed Secrets CLI |
| `kustomize` | Kubernetes config customization |
| `kyverno` | Kubernetes policy engine |
| `kubecolor` | Colorized kubectl output |
| `kubeconform` | Kubernetes manifest validator |
| `kube-linter` | Kubernetes lint tool |
| `kubens` | Namespace switcher |
| `kubent` | Deprecated API checker |
| `velero` | Backup & restore |
| `popeye` | Kubernetes cluster sanitizer |
| `trivy` | Container vulnerability scanner |
| `conftest` | Policy testing với OPA |
| `skopeo` | Container image operations |
| `nerdctl` | containerd CLI |

### Security / Secrets

| Tool | Mô tả |
|------|-------|
| `sops` | Secrets encryption |
| `age` | Simple file encryption |
| `vault` | HashiCorp Vault CLI |
| `infisical` | Secrets management |
| `talisman` | Git hook secrets scanner |

### Shell / Terminal

| Tool | Mô tả |
|------|-------|
| `zsh` | Z shell |
| `antidote` | Zsh plugin manager |
| `starship` | Cross-shell prompt |
| `direnv` | Per-directory env vars |
| `tmux` | Terminal multiplexer |
| `zoxide` | Smart `cd` replacement |
| `mcfly` | Smart shell history (Ctrl+R) |
| `fzf` | Fuzzy finder |
| `thefuck` | Correct last command |

### File / Text utilities

| Tool | Mô tả |
|------|-------|
| `jq` | JSON processor |
| `yq` | YAML processor |
| `bat` | `cat` với syntax highlight |
| `eza` | `ls` hiện đại |
| `fd` | `find` nhanh hơn |
| `ripgrep` | `grep` nhanh hơn |
| `chezmoi` | Dotfile manager |
| `rsync` | File sync |

### Dev tools

| Tool | Mô tả |
|------|-------|
| `uv` | Python package manager |
| `bashly` | Bash CLI generator |
| `gem` | RubyGems |
| `claude` | Claude Code CLI |
| `copilot` | GitHub Copilot CLI |
| `tailscale` | VPN mesh network |
| `trino` | Distributed SQL CLI |
| `gum` | Shell script UI components |
| `hyperfine` | Benchmarking tool |
| `viddy` | Modern `watch` command |
| `btop` | Resource monitor |
| `fastfetch` | System info tool |
| `git` | Distributed version control system |
| `bats` | Bash Automated Testing System |

## Environment variables

| Biến | Mặc định | Mô tả |
|------|----------|-------|
| `GITHUB_TOKEN` | — | GitHub API token (tăng rate limit từ 60 lên 5000 req/hr cho `gc outdated`) |
| `GT_DOWNLOAD_TIMEOUT` | `30` | Timeout tải xuống (giây) |

## Development

```shell
# Khởi động shell trong Docker
docker compose run --rm shell bash

# Chạy tests
docker compose run --rm test

# Build CLI sau khi sửa src/
bashly generate
```

Codebase dùng [Bashly](https://bashly.dev) — các commands định nghĩa trong `src/bashly.yml` và `src/commands/`, logic cài đặt trong `src/lib/`.

## Reference

- https://bashly.dev
- https://github.com/gruntwork-io/bash-commons
- https://github.com/bitnami/containers/tree/main/bitnami/pgpool/4/debian-12
- https://github.com/ppo/bash-colors
- https://github.com/charmbracelet/gum
- https://github.com/kward/shflags
- https://github.com/kvz/bash3boilerplate
- https://github.com/webinstall/webi-installers
