# Roadmap — OS-Scripts CLI (`gt`)

Dự án `os-scripts` cung cấp CLI `gt` để cài đặt, gỡ cài đặt và kiểm tra phiên bản các DevOps tool phổ biến trên Linux/macOS, dựa trên framework [Bashly](https://bashly.dev).

---

## Giai đoạn 1: Foundation — Xây dựng nền tảng CLI ✅

**Mục tiêu:** Thiết lập khung sườn CLI và hỗ trợ đủ 25 tool cốt lõi.

- [x] Khởi tạo dự án với Bashly, tạo lệnh `gt`
- [x] Thiết kế registry pattern: mỗi tool có file cấu hình riêng trong `src/lib/registry/`
- [x] Xây dựng generic installer engine (`generic_install.sh`) hỗ trợ `binary`, `tar.gz`, `zip`, `pip`
- [x] Xây dựng generic uninstaller engine (`generic_uninstall.sh`)
- [x] Hỗ trợ cài đặt 25 tool: kubectl, k9s, kustomize, krew, kubent, kubens, kubecolor, kyverno, kube-linter, popeye, kubeseal, conftest, sops, age, trivy, argocd, velero, kubeconform, vault, direnv, btop, fastfetch, zsh, antidote, thefuck
- [x] Lệnh `gt install <tool> [--version VERSION] [--force]`
- [x] Lệnh `gt uninstall <tool>`
- [x] Lệnh `gt outdated [tool] [--all]` — so sánh phiên bản đã cài với phiên bản mới nhất
- [x] Lệnh `gt install multi` — cài nhiều tool cùng lúc
- [x] Chuẩn hóa cấu trúc thư mục `src/` theo chuẩn Bashly
- [x] Template variable substitution: `${VERSION}`, `${DETECT_OS}`, `${DETECT_ARCH}`, `${V_VERSION}`, `${TAG}`
- [x] Platform detection và architecture mapping (amd64/arm64, linux/darwin)
- [x] OS/ARCH mapping per-tool (e.g., trivy dùng `Linux`/`macOS`, kubens dùng `x86_64`)
- [x] Tài liệu hóa workflow thêm tool mới trong `.agents/skills/install-tool/`

---

## Giai đoạn 2: Refactor & Bug Fixes — Sửa lỗi và tối ưu code ✅

**Mục tiêu:** Sửa các lỗi tiềm ẩn, loại bỏ code trùng lặp, cải thiện tính nhất quán.

- [x] **Fix lỗi escaping nghiêm trọng**: 16 registry file dùng `${VAR}` trong double-quote ở global scope → biến expand rỗng khi source → URL download sai. Sửa thành `\${VAR}` để lưu literal placeholder
- [x] **Fix trivy**: `${DETECT_OS_CAP}` (undefined) → `${DETECT_OS}`, `_64bit` hardcode → `${DETECT_ARCH}` — ARM64 hoạt động đúng với OS_MAP/ARCH_MAP sẵn có
- [x] **Fix BIN_PATH substitution**: `generic_install.sh` đọc `BIN_PATH` mà không chạy template substitution → krew, velero cài sai binary
- [x] **Fix version detection cho tool tên có hyphen**: `kube-linter` — `version_helpers.sh` không convert hyphen thành underscore khi tìm function name và tạo variable name
- [x] **Dedup `fetch_local_version`**: 16 registry file có function body giống hệt nhau → extract thành `_default_fetch_local_version()` fallback trong `version_helpers.sh`, xóa 16 function redundant (~48 dòng)
- [x] **Extract archive helper**: tar.gz và zip branch trong `generic_install.sh` có ~20 dòng logic post-extraction giống nhau → extract thành `_install_from_extracted_dir()` helper
- [x] **Nhất quán uninstall commands**: 6 file dùng `uninstall_tool` trực tiếp, `thefuck` có custom pip logic riêng → chuyển tất cả sang `run_generic_uninstall`

---

## Giai đoạn 3: Reliability & Security — Độ tin cậy và bảo mật

**Mục tiêu:** Tăng độ tin cậy khi tải về và cài đặt, thêm bảo vệ chống artifact bị thay thế.

- [ ] **Checksum verification**: Tải `.sha256` hoặc `.sha256sum` từ GitHub Release và xác minh trước khi extract. Thêm registry field `TOOL_CHECKSUM_FILE` cho tool có naming khác. Thêm flag `--no-verify` để bỏ qua khi cần
- [ ] **GitHub API authentication**: Hỗ trợ `GITHUB_TOKEN` env var để tăng rate limit từ 60 lên 5000 req/hr — quan trọng nhất cho lệnh `gt outdated` khi check 25 tool
- [ ] **Retry logic cho network**: Tự động retry với exponential backoff (3 lần: 2s/4s/8s) khi `curl` thất bại vì timeout hoặc rate limit
- [ ] **Validate asset URL trước khi download**: HEAD request để kiểm tra URL trả về 200 trước khi tải, thông báo lỗi rõ ràng thay vì fail sau khi đã download xong
- [ ] **Atomic install**: Download → verify checksum → kiểm tra binary chạy được (`tool --version`) → mới copy vào `/usr/local/bin` — tránh binary broken nếu download bị interrupt
- [ ] **Dry-run mode**: Flag `--dry-run` để preview URL download, checksum file, và thao tác sẽ thực hiện mà không cài thật
- [ ] **Kiểm tra disk space**: Ước lượng archive size trước khi extract, cảnh báo nếu free space không đủ
- [ ] **Timeout configuration**: Env var `GT_DOWNLOAD_TIMEOUT` để override timeout mặc định của curl

---

## Giai đoạn 4: Version Management — Quản lý phiên bản nâng cao

**Mục tiêu:** Cải thiện khả năng upgrade, pin phiên bản, và theo dõi state đã cài.

- [ ] **`gt upgrade <tool>`**: Upgrade tool lên phiên bản mới nhất — tương đương `install --force --version latest`
- [ ] **`gt upgrade --all`**: Upgrade tất cả tool đang outdated một lần; hỏi confirm trước khi thực hiện
- [ ] **`gt list`**: Liệt kê tất cả tool hỗ trợ kèm: phiên bản đã cài, phiên bản mới nhất, trạng thái (up-to-date / outdated / not installed)
- [ ] **State tracking**: Lưu thông tin đã cài vào `~/.local/share/gt/state.json` — tên tool, phiên bản, install method, ngày cài — để `gt list` và `gt outdated` không phụ thuộc hoàn toàn vào `tool --version`
- [ ] **`gt pin <tool> <version>`**: Pin tool ở phiên bản cụ thể; `gt outdated` và `gt upgrade` bỏ qua tool đã pin
- [ ] **`gt unpin <tool>`**: Gỡ pin, trở lại theo dõi phiên bản mới nhất
- [ ] **`gt info <tool>`**: Hiển thị đầy đủ thông tin tool: phiên bản đã cài, phiên bản mới nhất, GitHub repo, install type, asset pattern, bin path, ngày cài

---

## Giai đoạn 5: Profile & Bootstrap — Cài theo vai trò

**Mục tiêu:** Cho phép cài nhóm tool theo profile (workstation, jumpbox, k8s-admin...) chỉ bằng một lệnh.

- [ ] **`gt bootstrap <profile>`**: Cài toàn bộ tool theo profile định nghĩa trước
  - `gt bootstrap workstation` — zsh, antidote, direnv, btop, fastfetch, kubectl, k9s, argocd, sops, age, trivy, vault
  - `gt bootstrap jumpbox` — kubectl, k9s, kubens, kubecolor, krew, sops, age, trivy, argocd, velero
  - `gt bootstrap k8s-admin` — kubectl, k9s, krew, kustomize, kyverno, kubeconform, kube-linter, kubent, popeye, velero, argocd, kubeseal, conftest
  - `gt bootstrap security` — trivy, sops, age, kubeseal, kyverno, conftest, kubeconform, vault
- [ ] **Custom profile**: File `~/.config/gt/profiles.yaml` để định nghĩa profile riêng
- [ ] **`gt profile list`**: Liệt kê tất cả profile có sẵn và danh sách tool của mỗi profile
- [ ] **`gt profile show <name>`**: Xem tool trong một profile cụ thể
- [ ] **Parallel install trong bootstrap**: Cài nhiều tool đồng thời với `xargs -P` hoặc background jobs để tăng tốc

---

## Giai đoạn 6: Tool Coverage — Mở rộng danh sách tool

**Mục tiêu:** Thêm các tool quan trọng còn thiếu theo TOOLS.md.

**Container & Registry:**
- [ ] `helm` — Kubernetes package manager
- [ ] `helmfile` — Multi-release Helm management
- [ ] `skopeo` — Registry-to-registry image copy (air-gap)
- [ ] `crane` — Remote image operations
- [ ] `oras` — OCI artifact push/pull
- [ ] `dive` — Image layer analyzer

**Kubernetes & GitOps:**
- [ ] `stern` — Multi-pod log tailing
- [ ] `kubectx` — Cluster context switcher
- [ ] `flux` — GitOps CD (Flux v2)
- [ ] `kubescape` — K8s security posture scanner
- [ ] `pluto` — Deprecated API detector (CI-oriented, bổ sung kubent)

**Security & Supply Chain:**
- [ ] `syft` — SBOM generator
- [ ] `grype` — Vulnerability scanner (SBOM-aware, bổ sung trivy)
- [ ] `cosign` — Image signing/verification
- [ ] `gitleaks` — Git secret scanner
- [ ] `checkov` — IaC security scanner (Terraform/K8s/Dockerfile)
- [ ] `semgrep` — SAST / custom rule scanner
- [ ] `step` — Certificate/PKI CLI (Let's Encrypt, mTLS)

**Modern CLI:**
- [ ] `jq` — JSON processor (P0 core)
- [ ] `yq` — YAML processor (P0 core)
- [ ] `fzf` — Fuzzy finder
- [ ] `bat` — cat replacement
- [ ] `fd` — find replacement
- [ ] `ripgrep` — grep replacement
- [ ] `eza` — ls replacement
- [ ] `delta` — Git diff viewer
- [ ] `lazygit` — Git TUI
- [ ] `zoxide` — Smart cd

**IaC & Automation:**
- [ ] `terraform` / `opentofu` — IaC engine
- [ ] `terragrunt` — Terraform wrapper
- [ ] `ansible` — Config management (via pip)
- [ ] `task` (taskfile) — Task runner

**Backup & Sync:**
- [ ] `restic` — File backup
- [ ] `rclone` — Object storage sync (S3/MinIO/Drive)

---

## Giai đoạn 7: UX & Developer Experience

**Mục tiêu:** Cải thiện trải nghiệm, đặc biệt cho người mới onboard.

- [ ] **Interactive version picker**: `gum choose` cho phép chọn phiên bản bằng mũi tên thay vì gõ `--version`
- [ ] **Better confirmation prompts**: `gum confirm` trước khi uninstall (thay `read -p` hiện tại)
- [ ] **Download spinner**: `gum spin` thay curl progress bar
- [ ] **`gt install --interactive`**: Wizard từng bước — chọn tool → chọn phiên bản → xem checksum → xác nhận
- [ ] **Tab completion**: Tự sinh bash/zsh/fish completion script từ Bashly definitions
- [ ] **`gt doctor`**: Kiểm tra môi trường — có đủ curl/tar/unzip/pip3 không, GitHub API rate limit còn bao nhiêu, quyền write `/usr/local/bin` không
- [ ] **Shell integration**: `gt shell-init` tích hợp vào `~/.zshrc`/`~/.bashrc` để tự thêm PATH nếu cần
- [ ] **Consistent error messages**: Chuẩn hóa format lỗi — `[ERROR]`, `[WARN]`, `[INFO]` với màu; tất cả exit code nhất quán
- [ ] **`gt completions <shell>`**: Sinh script tab completion cho bash/zsh/fish

---

## Giai đoạn 8: Plugin & Extensibility — Mở rộng hệ sinh thái

**Mục tiêu:** Cho phép cộng đồng và người dùng thêm tool tùy chỉnh mà không cần fork.

- [ ] **User-defined registry**: `~/.config/gt/registry/` — người dùng tự thêm file registry cho tool riêng theo cùng format với `src/lib/registry/`
- [ ] **`gt registry add <url>`**: Tải và cài registry file từ URL (GitHub raw, Gist, v.v.)
- [ ] **`gt registry list`**: Liệt kê tất cả registry đang active (built-in + user-defined)
- [ ] **`gt registry validate <file>`**: Validate registry file có đúng format và asset pattern resolve được không
- [ ] **Community registry**: Repository riêng `os-scripts-registry` chứa registry cho tool không nằm trong core
- [ ] **Dependency declarations**: Registry có thể khai báo `TOOL_REQUIRES="kubectl"` — `gt install` tự cài dependency nếu thiếu
- [ ] **Post-install hooks**: Registry có thể định nghĩa hàm `tool_post_install()` để chạy sau khi cài (ví dụ: `krew update` sau khi cài krew, tạo symlink, v.v.)

---

## Giai đoạn 9: Reliability Improvements — Cải thiện vận hành

**Mục tiêu:** Hoạt động ổn định trên nhiều môi trường, kể cả restricted/offline.

- [ ] **Offline/air-gap mode**: `--offline` flag + pre-downloaded archive directory. `GT_OFFLINE_DIR=/path/to/archives gt install kubectl` sẽ dùng file local thay vì download
- [ ] **Rollback**: `gt rollback <tool>` — phục hồi về phiên bản trước đó (lưu binary cũ trong `~/.local/share/gt/backups/`)
- [ ] **`gt repair <tool>`**: Kiểm tra và re-install tool nếu binary corrupt hoặc thiếu execute permission
- [ ] **Configurable install dir**: Env var `GT_BIN_DIR` (default `/usr/local/bin`) để cài vào thư mục khác (phù hợp non-root, container, WSL2)
- [ ] **Non-root install**: Khi không có sudo, tự động cài vào `~/.local/bin` và thêm vào PATH
- [ ] **`GT_CACHE_DIR`**: Cache archive đã tải để tránh re-download khi reinstall
- [ ] **Shell env check**: Cảnh báo nếu `~/.local/bin` không nằm trong `PATH` sau khi cài non-root
- [ ] **Windows WSL2 support**: Test và document cụ thể cho WSL2 Ubuntu/Debian

---

## Giai đoạn 10: CI/CD & Distribution — Phân phối và kiểm thử tự động

**Mục tiêu:** Tự động hóa kiểm thử, release, và phân phối `gt` CLI.

- [ ] **GitHub Actions — integration tests**: Test thật `gt install <tool>` trên ubuntu-latest và macos-latest, kiểm tra binary chạy được sau khi cài
- [ ] **Pattern validation**: Script tự động kiểm tra tất cả ASSET_PATTERN resolve đúng URL tồn tại trên GitHub Release (dùng HEAD request)
- [ ] **Registry lint CI**: Kiểm tra mọi registry file có đúng format, có `INSTALL_TYPE`, không có unescaped `${VAR}` trong double-quote
- [ ] **Release automation**: Auto-generate CHANGELOG từ commit messages; tạo GitHub Release khi push tag
- [ ] **Install script**: `curl -fsSL .../install.sh | bash` — tải và setup `gt` trên máy mới hoàn toàn tự động
- [ ] **Docker image `ghcr.io/ttungbmt/gt`**: Image multi-arch (amd64/arm64) chứa `gt` CLI và tất cả tool đã cài; dùng làm base cho CI runner
- [ ] **Homebrew formula**: `brew install ttungbmt/tap/gt` cho macOS/Linux
- [ ] **Version badge**: Badge phiên bản mới nhất trong README
- [ ] **Dependabot / Renovate**: Tự động phát hiện khi tool trong registry có phiên bản mới, tạo PR update

---

## Trạng thái tổng quan

| Giai đoạn | Trạng thái | Ghi chú |
|---|---|---|
| 1. Foundation | ✅ Hoàn thành | 25 tool, install/uninstall/outdated |
| 2. Refactor & Bug Fixes | ✅ Hoàn thành | Escaping fix, dedup, archive helper |
| 3. Reliability & Security | 🔲 Chưa bắt đầu | Checksum, retry, dry-run, atomic install |
| 4. Version Management | 🔲 Chưa bắt đầu | upgrade, list, pin, state tracking |
| 5. Profile & Bootstrap | 🔲 Chưa bắt đầu | bootstrap workstation/jumpbox/k8s-admin |
| 6. Tool Coverage | 🔲 Chưa bắt đầu | helm, skopeo, syft, cosign, jq, bat, ... |
| 7. UX & Developer Experience | 🔲 Chưa bắt đầu | gum, completion, gt doctor |
| 8. Plugin & Extensibility | 🔲 Chưa bắt đầu | User registry, hooks, dependencies |
| 9. Reliability Improvements | 🔲 Chưa bắt đầu | Offline mode, rollback, non-root |
| 10. CI/CD & Distribution | 🔲 Chưa bắt đầu | Tests, install script, Docker, Homebrew |
