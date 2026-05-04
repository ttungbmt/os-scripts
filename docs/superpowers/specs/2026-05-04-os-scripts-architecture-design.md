# os-scripts Architecture — Design Spec

- **Date**: 2026-05-04
- **Status**: Approved (brainstorm), pending implementation plan
- **Owner**: ttungbmt
- **Repo**: `ttungbmt/os-scripts`

## 1. Mục tiêu

Thiết kế folder structure + framework để quản lý **100+ tools/modules** cài đặt trên Linux servers, đáp ứng:

1. **Cross-OS by default**, OS-specific chỉ là override khi cần (Oracle Linux 9, Ubuntu, …).
2. **Dễ mở rộng**: thêm 1 tool mới ≤ 5 phút, không phải sửa code core.
3. **DRY tuyệt đối**: lib hóa toàn bộ logic chung (download, github-release resolve, version-gate, extract, place-bin, log, OS detect, package-manager abstraction).
4. **Hỗ trợ 2 cách dùng song song**:
   - `bash <(curl …/install-<tool>.sh)` — online one-shot (current usage).
   - `./osx install <tool>` — local CLI dispatcher khi đã clone repo.
5. **Reproducible**: cố định version repo (`OSX_REF`) + version từng tool (preset / `--version`).
6. **Required-tools cho repo dự án**: 1 dòng curl trong README dự án X kéo về cả nhóm tool.

## 2. Non-goals

- Không thay thế Ansible/Salt cho config-management quy mô lớn.
- Không quản lý service runtime sau khi cài (chỉ enable cơ bản qua hook).
- Không tự build tool từ source (chỉ tải release artifact / dùng package manager / run installer chính thức).

## 3. Use cases

| # | Use case | Lệnh |
|---|---|---|
| U1 | Online one-shot cài 1 tool | `bash <(curl -fsSL .../modules/tools/kustomize/install.sh)` |
| U2 | Online + pin repo version | `OSX_REF=v1.2.0 bash <(curl ...)` |
| U3 | Local clone, cài 1 tool | `./osx install kustomize` |
| U4 | Local nhưng force online (đỡ pull) | `OSX_FORCE_ONLINE=1 ./osx install kustomize` |
| U5 | Cài bundle cho repo dự án | `curl …/bin/osx-bootstrap \| bash -s -- preset repo-required` |
| U6 | Liệt kê / xem info | `./osx list --domain k8s` ; `./osx info kustomize` |
| U7 | Dry-run kiểm tra trước khi cài | `./osx install kustomize --dry-run` |

## 4. Top-level layout

```
os-scripts/
├── osx                          # CLI dispatcher (entrypoint chính)
├── bin/
│   └── osx-bootstrap            # one-liner installer (curl | bash)
├── lib/                         # shared bash libraries (DRY core)
│   ├── _loader.sh               # local-first / online-fallback bootstrap
│   ├── core/                    # log, die, trap, args, env
│   ├── os/                      # detect_os, detect_arch, pkg-manager abstraction
│   ├── net/                     # download, github (releases, checksum), proxy
│   ├── version/                 # semver, version_gate, installed_version
│   ├── install/
│   │   ├── runner.sh            # osx::module::run (Template Method flow)
│   │   └── strategies/          # github-release.sh, url-tarball.sh, ...
│   └── registry.sh              # discover modules + manifests
├── modules/                     # cross-OS modules (single source of truth)
│   ├── _template/               # cookie-cutter cho tool mới
│   ├── tools/                   # CLI tools: kustomize, helm, k9s, gh, task, uv, ...
│   ├── k8s/                     # kubectl, helmfile, kubelet-prereq
│   ├── runtime/                 # docker, python312, node
│   ├── network/                 # nmcli-static, dhcp-to-static, scan-ip
│   ├── security/                # ssh-hardening, firewalld, selinux, ssh-keygen
│   ├── storage/                 # lvm, nfs-client
│   └── bootstrap/               # repos, mirrors, base packages
├── os/                          # CHỈ chứa override khi cross-OS không đủ
│   ├── oracle-linux/9/modules/
│   ├── oracle-linux/common/modules/
│   ├── ubuntu/22.04/modules/
│   └── ubuntu/common/modules/
├── presets/                     # bundle: k8s-node.yml, devbox.yml, ...
├── templates/                   # jinja/envsubst chung
├── tests/
│   ├── bats/                    # unit tests cho lib + manifest validator
│   └── smoke/                   # docker/vagrant matrix
├── docs/superpowers/specs/
├── Taskfile.yml                 # dev shortcut (lint, test, release)
└── README.md
```

**Nguyên tắc bố cục:**

- `modules/` là single source of truth — cross-OS theo mặc định.
- `os/<distro>/<ver>/modules/` chỉ tồn tại khi 1 module **không thể** cross-OS (ví dụ `dnf-mirror`, `ol9-repos`) hoặc cần override file đường dẫn giống hệt module trong `modules/`.
- `lib/` không bao giờ chứa logic của tool cụ thể.
- Module không tự code lại download/version/extract — phải gọi lib.

## 5. Loader (local-first, online-fallback)

`lib/_loader.sh` là điểm vào duy nhất mà mọi script source. Tự định vị `$OSX_HOME` theo thứ tự:

1. `OSX_FORCE_ONLINE=1` → bỏ qua local, dùng remote.
2. `$OSX_HOME` (env) → đường dẫn user chỉ định.
3. `$_SCRIPT_DIR/../..` chứa `lib/_loader.sh` → đang chạy trong repo clone.
4. `$HOME/.osx/<ref>/` chứa `lib/` → cache đã tải trước đó.
5. `/usr/local/share/osx/` chứa `lib/` → cài đặt hệ thống.
6. Online fallback: tải tarball `codeload.github.com/ttungbmt/os-scripts/tar.gz/<ref>` (default `master`) vào `$HOME/.osx/<ref>/`, source từ đó.

**Tải nguyên tarball** (không tải từng file lib) để: 1 round-trip, có sẵn `modules/` cho lệnh kế tiếp, dễ pin SHA.

### Biến môi trường

| Var | Default | Tác dụng |
|---|---|---|
| `OSX_HOME` | (auto) | Trỏ thẳng tới repo / cài đặt local |
| `OSX_REF` | `master` | Branch / tag / SHA khi online |
| `OSX_FORCE_ONLINE` | `0` | `1` = bỏ qua local |
| `OSX_CACHE_DIR` | `$HOME/.osx` | Thư mục cache tarball |
| `OSX_PROXY` | (none) | Prepend `gh-proxy.com` cho user TQ |
| `GH_TOKEN` | (none) | API rate-limit khi resolve latest |

## 6. Module structure

Mỗi module = 1 folder dưới `modules/<domain>/<name>/`. Cấu trúc theo 3 dạng:

### 6.1 — Cross-OS thuần (90% trường hợp)

```
modules/tools/kustomize/
├── manifest.sh
└── install.sh
```

`install.sh` là Template Method 5 dòng:
```bash
#!/usr/bin/env bash
set -Eeuo pipefail
# shellcheck disable=SC1090
source "$(dirname "${BASH_SOURCE[0]}")/../../../lib/_loader.sh"   # local
osx::loader::ensure                                                # auto-fallback online
osx::module::run "$(dirname "${BASH_SOURCE[0]}")" "$@"
```

### 6.2 — OS-specific branching (5%)

```
modules/runtime/docker/
├── manifest.sh                  # SOURCE="os-strategy"
├── install.sh                   # cùng template
└── strategies/
    ├── oracle-linux.sh
    ├── ubuntu.sh
    └── _common.sh               # post-install chung
```

`osx::module::run` thấy `SOURCE=os-strategy` → detect OS → source `strategies/<distro>.sh` → `_common.sh`.

### 6.3 — Module non-tool (network/security/storage)

```
modules/network/nmcli-static/
├── manifest.sh                  # SOURCE="script"
├── install.sh
└── templates/
    └── ifcfg.j2
```

### 6.4 — Module không cross-OS được

Đặt vào `os/<distro>/<ver>/modules/<domain>/<name>/` thay vì `modules/` để không giả vờ cross-OS:

```
os/oracle-linux/9/modules/bootstrap/dnf-mirror/
├── manifest.sh
└── install.sh
```

Registry tự gộp `modules/` + `os/<current-distro>/<ver>/modules/` khi list/install. OS override thắng cross-OS nếu trùng path.

## 7. Manifest schema

Bash variables (không YAML) để source thẳng vào shell, interpolate `${VERSION}/${OS}/${ARCH}` tự nhiên.

```bash
# Bắt buộc
NAME="kustomize"
DOMAIN="tools"
SOURCE="github-release"            # github-release | url-tarball | script-installer
                                   # | pkg-manager | os-strategy | script

# Khuyến nghị
DESCRIPTION="K8s native config management"
HOMEPAGE="https://kustomize.io"
BIN_NAME="kustomize"               # default = NAME
TAGS=(k8s cli)
DEPENDS=()                         # tên module phải có trước
CONFLICTS=()
VERIFY_CMD='kustomize version'

# OS/arch normalization (optional override)
OS_MAP=( [linux]=linux [darwin]=darwin )
ARCH_MAP=( [x86_64]=amd64 [aarch64]=arm64 )

# Hooks
PRE_INSTALL=""
POST_INSTALL=""

# --- Tham số riêng strategy (ví dụ github-release) ---
REPO="kubernetes-sigs/kustomize"
TAG_PREFIX="kustomize/v"
ASSET='kustomize_v${VERSION}_${OS}_${ARCH}.tar.gz'    # SINGLE-QUOTE để hoãn interp
ARCHIVE_TYPE="tar.gz"               # tar.gz | zip | raw
EXTRACT_PATH="kustomize"
CHECKSUM_FILE="checksums.txt"
CHECKSUM_ALGO="sha256"
```

**Quy tắc**:
- Manifest **không có logic** (không if/loop). Mọi cái đặc biệt → dùng strategy `script` hoặc hook function trong `install.sh`.
- `osx::module::validate` kiểm field bắt buộc, fail-fast.

## 8. Strategy catalog

| `SOURCE` | Use case | Field bắt buộc | Lib xử lý |
|---|---|---|---|
| `github-release` | kustomize, helm, k9s, gh, task, uv, lazydocker, kubectl, helmfile | `REPO`, `ASSET` | resolve latest tag → download → checksum → extract → place_bin |
| `url-tarball` | tool host ngoài GitHub | `URL` | download → verify → extract |
| `script-installer` | rustup, nvm, ollama | `INSTALLER_URL` | curl \| bash + args, hỗ trợ `OSX_PROXY` |
| `pkg-manager` | git, ansible, python312 | `PACKAGES`, `REPO_FILES?` | abstract dnf/apt qua `lib/os/pkg.sh` |
| `os-strategy` | docker, kubernetes-prereq | (folder `strategies/`) | source `strategies/<distro>.sh` rồi `_common.sh` |
| `script` | network/security/storage/bootstrap | (none) | chạy thẳng `install.sh`, lib chỉ cấp helpers |

Thêm strategy mới = thêm 1 file vào `lib/install/strategies/` + đăng ký key. **Open/Closed**.

## 9. Run flow (Template Method)

`osx::module::run` cố định flow sau, strategy chỉ fill phần biến thiên:

```
parse_args (--version --upgrade --downgrade --force --dry-run --prefix --no-verify)
  → load manifest.sh
  → osx::module::validate
  → for dep in DEPENDS: osx::module::run dep        (recursive)
  → resolve VERSION (latest hoặc user-pin)
  → detect OS/ARCH, apply OS_MAP / ARCH_MAP
  → installed_version + version_gate
       → action ∈ {skip, install, upgrade, downgrade, abort}
  → strategy_dispatch "$SOURCE"                      ← phần biến thiên DUY NHẤT
       (download → verify → extract → place_bin / pkg install / installer)
  → run PRE_INSTALL → POST_INSTALL hooks
  → VERIFY_CMD smoke test
  → ghi $OSX_CACHE_DIR/state.json (name, version, time, source)
```

Module không chạm vào các bước trên — chúng chỉ khai báo. **Đây là điểm DRY mạnh nhất.**

## 10. CLI dispatcher `osx`

```
osx <command> [args...]

COMMANDS
  install <name>...             cài 1 hay nhiều module
  remove  <name>...             nếu module có uninstall.sh
  list [--domain d] [--tag t]   liệt kê module (gộp modules/ + os override)
  info    <name>                in manifest + nguồn cài
  preset  <name|file>           cài bundle theo presets/<name>.yml
  update                        refresh cache online ($OSX_REF)
  doctor                        check OS, arch, deps, network, proxy
  version                       bản osx + OSX_REF đang dùng

GLOBAL FLAGS (forward vào module)
  --version <x> --upgrade --downgrade --force --dry-run --no-verify --prefix <dir>
```

`osx` chỉ map `name → modules/*/<name>/install.sh` rồi `exec` với args. Module vẫn standalone (chạy thẳng được).

## 11. Presets

```yaml
# presets/devbox.yml
name: devbox
description: Local dev environment
modules:
  - tools/git
  - tools/gh: { version: "2.55.0" }
  - tools/task
  - tools/uv: { version: "0.5.0", flags: ["--upgrade"] }
post:
  - "git config --global init.defaultBranch main"
```

Cài: `osx preset devbox` (local) hoặc:

```bash
curl -fsSL https://raw.githubusercontent.com/ttungbmt/os-scripts/master/bin/osx-bootstrap | \
  OSX_REF=v1.2.0 bash -s -- preset repo-required
```

Pin `OSX_REF` + version trong preset → reproducible cho team/CI.

## 12. Patterns đã áp dụng

| Pattern | Áp dụng tại đâu |
|---|---|
| **DRY** | `lib/` + manifest declarative + strategy → 0 lặp code download/version/extract |
| **Template Method** | `osx::module::run` cố định flow, strategy fill biến thiên |
| **Strategy** | `SOURCE=` chọn strategy file; `os-strategy` chọn `strategies/<distro>.sh` |
| **Registry** | `lib/registry.sh` scan manifest, gộp OS override, sinh list cho CLI |
| **Convention over Configuration** | Folder name = NAME = BIN_NAME mặc định |
| **Open/Closed** | Thêm tool / strategy = thêm folder/file, không sửa core |
| **Single Responsibility** | Manifest = khai báo, install.sh = entrypoint, lib = logic chung |
| **Fail-fast** | manifest validator + `set -Eeuo pipefail` + version_gate |

## 13. Testing

| Tầng | Tool | Phạm vi | Tần suất |
|---|---|---|---|
| Lint | shellcheck + shfmt | toàn repo | mỗi push |
| Unit (lib) | bats-core | `version_gate`, `detect_os`, `extract_semver`, `resolve_latest_tag`, manifest validator | mỗi push |
| Module dry-run | bats + `--dry-run` | mọi module pass dry-run trên matrix `{linux,darwin}×{amd64,arm64}` | mỗi push |
| Smoke (VM) | docker `oraclelinux:9`, `ubuntu:22.04` | `osx preset k8s-node`, `VERIFY_CMD` pass | nightly |

## 14. Release & versioning

- **SemVer** trên repo (`v1.2.0`). User pin qua `OSX_REF=v1.2.0`.
- **KHÔNG** tag riêng cho từng tool. Latest tool version resolve at-runtime từ GitHub. Pin tool version qua `--version` hoặc preset.
- `CHANGELOG.md` chỉ ghi thay đổi lib / CLI / strategy (breaking). Thêm tool mới không cần entry.
- `Taskfile.yml` có task `release` → bump version → tag → GitHub Release.
- One-liner mặc định trỏ về `master` (rolling); ai cần ổn định → `OSX_REF=v<x.y.z>`.

## 15. Migration từ trạng thái hiện tại

Repo hiện có: `lib/` (đã viết) + `install-kustomize.sh` mẫu hoạt động được + `Taskfile.yml`. Migration tối thiểu:

1. Thêm `lib/_loader.sh` (local-first / online-fallback).
2. Thêm `lib/install/runner.sh` + `lib/install/strategies/github-release.sh`.
3. Refactor `install-kustomize.sh` → `modules/tools/kustomize/{manifest.sh, install.sh}`. Giữ `install-kustomize.sh` ở root làm shim mỏng (1 dòng `exec`).
4. Thêm `osx` dispatcher + `lib/registry.sh`.
5. Thêm `modules/_template/` để cookie-cutter tool mới.
6. Port các module cũ (helm, k9s, task, gh, uv, direnv, lazydocker, nerdctl, helmfile, kubectl) — mỗi cái 5 phút.
7. Bật CI: lint + unit + module dry-run.
8. Smoke matrix nightly (sau).

## 16. Mở rộng tương lai (out of scope spec này)

- `osx remove` + uninstall hooks per module.
- State file `$OSX_CACHE_DIR/state.json` để track cài gì.
- Self-update: `osx update` refresh cache.
- Hỗ trợ macOS / WSL bên cạnh Linux.
- Signing / cosign verify cho artifact.
- Telemetry opt-in.

## 17. Risks & mitigation

| Risk | Mitigation |
|---|---|
| Online fallback fail (no network) | Loader báo lỗi rõ + gợi ý `git clone` hoặc set `OSX_HOME` |
| GitHub API rate-limit khi resolve latest | Hỗ trợ `GH_TOKEN`; cho phép `--version` skip resolve |
| Asset name format thay đổi giữa các tool | `ASSET` template + `OS_MAP`/`ARCH_MAP` override per-manifest |
| Bash version cũ (<4) trên macOS | Yêu cầu bash ≥4 ở `osx doctor`; tài liệu hướng dẫn |
| Tool có installer "dirty" (write `~/.bashrc`) | Strategy `script-installer` chạy trong subshell, log rõ side-effects |
| OS override drift khỏi cross-OS | Convention: file path trong `os/.../modules/...` PHẢI trùng với `modules/...` để registry detect được override |
