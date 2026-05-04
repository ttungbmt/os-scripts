# Roadmap — OS-Scripts CLI (`gt`)

Dự án `os-scripts` cung cấp CLI `gt` để cài đặt, gỡ cài đặt và kiểm tra phiên bản 25 DevOps tool phổ biến trên Linux/macOS, dựa trên framework [Bashly](https://bashly.dev).

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

- [ ] **Checksum verification**: Tải `.sha256` hoặc `.sha256sum` từ GitHub Release và xác minh trước khi extract. Thêm flag `--no-verify` để bỏ qua khi cần
- [ ] **Retry logic cho network**: Tự động retry với exponential backoff khi `curl` thất bại (timeout, rate limit)
- [ ] **GitHub API authentication**: Hỗ trợ `GITHUB_TOKEN` env var để tăng rate limit từ 60 lên 5000 req/hr, đặc biệt quan trọng cho lệnh `gt outdated`
- [ ] **Dry-run mode**: Flag `--dry-run` để preview URL download và thao tác sẽ thực hiện mà không cài thật
- [ ] **Validate asset pattern trước khi download**: Kiểm tra URL có trả về 200 trước khi xử lý, thông báo lỗi rõ ràng hơn
- [ ] **Kiểm tra disk space** trước khi extract archive lớn
- [ ] **Atomic install**: Download vào temp dir, kiểm tra binary chạy được (`--version`), rồi mới copy vào `/usr/local/bin` — tránh để binary broken nếu download bị lỗi giữa chừng

---

## Giai đoạn 4: Version Management — Quản lý phiên bản nâng cao

**Mục tiêu:** Cải thiện khả năng upgrade, pin phiên bản, và theo dõi state đã cài.

- [ ] **`gt upgrade <tool>`**: Upgrade tool lên phiên bản mới nhất (hoặc phiên bản chỉ định), tương đương `install --force --version latest`
- [ ] **`gt upgrade --all`**: Upgrade tất cả tool đang cài và đã lỗi thời một lần
- [ ] **`gt list`**: Liệt kê tất cả tool được hỗ trợ kèm phiên bản đã cài và phiên bản mới nhất
- [ ] **State tracking**: Lưu thông tin đã cài vào `~/.local/share/gt/state.json` (tên tool, phiên bản, ngày cài) để `gt list` và `gt outdated` không phụ thuộc vào `--version` của binary
- [ ] **`gt pin <tool> <version>`**: Pin tool ở phiên bản cụ thể, `gt outdated` sẽ bỏ qua tool đã pin
- [ ] **`gt info <tool>`**: Hiển thị thông tin tool: phiên bản đã cài, phiên bản mới nhất, GitHub repo, install type, asset pattern

---

## Giai đoạn 5: Tool Coverage — Mở rộng danh sách tool

**Mục tiêu:** Thêm các tool quan trọng còn thiếu theo TOOLS.md.

**Kubernetes & GitOps:**
- [ ] `helm` — Kubernetes package manager (hiện chưa có)
- [ ] `helmfile` — Multi-release Helm management
- [ ] `stern` — Multi-pod log tailing
- [ ] `kubectx` — Cluster context switcher
- [ ] `flux` — GitOps CD alternative

**Container & Registry:**
- [ ] `skopeo` — Registry-to-registry image copy
- [ ] `crane` — Remote image operations
- [ ] `oras` — OCI artifact push/pull
- [ ] `dive` — Image layer analyzer

**Security & Supply Chain:**
- [ ] `syft` — SBOM generator
- [ ] `grype` — Vulnerability scanner (SBOM-aware)
- [ ] `cosign` — Image signing/verification
- [ ] `gitleaks` — Secret scanner
- [ ] `checkov` — IaC security scanner

**Modern CLI:**
- [ ] `jq` — JSON processor
- [ ] `yq` — YAML processor
- [ ] `fzf` — Fuzzy finder
- [ ] `bat` — cat replacement
- [ ] `fd` — find replacement
- [ ] `ripgrep` — grep replacement
- [ ] `delta` — Git diff viewer
- [ ] `lazygit` — Git TUI

---

## Giai đoạn 6: UX & Interactive Mode

**Mục tiêu:** Cải thiện trải nghiệm người dùng, đặc biệt cho người mới.

- [ ] **Interactive version picker**: Dùng `gum choose` để chọn phiên bản bằng mũi tên thay vì gõ `--version`
- [ ] **Confirmation prompts**: Dùng `gum confirm` trước khi uninstall (thay vì `read -p` hiện tại)
- [ ] **Better spinners**: Dùng `gum spin` cho progress download thay vì curl progress bar
- [ ] **`gt install --interactive`**: Wizard hỏi từng bước: chọn tool → chọn phiên bản → xác nhận
- [ ] **Color output improvements**: Phân biệt rõ hơn giữa success/warning/error với consistent format
- [ ] **Tab completion**: Tự động sinh bash/zsh completion script từ Bashly cho `gt`

---

## Giai đoạn 7: CI/CD & Distribution

**Mục tiêu:** Dễ dàng tích hợp vào pipeline CI và phân phối.

- [ ] **GitHub Actions workflow**: CI test tự động khi thêm tool mới hoặc thay đổi registry
- [ ] **Pattern validation test**: Script kiểm tra tất cả ASSET_PATTERN có resolve đúng với platform thật
- [ ] **Release automation**: Tag + changelog tự động khi merge PR
- [ ] **Install script**: `curl -fsSL .../install.sh | bash` để bootstrap `gt` trên máy mới
- [ ] **Docker image**: Image chứa `gt` và tất cả 25 tool đã cài cho CI runner
- [ ] **Multi-arch CI**: Test trên linux/amd64 và linux/arm64

---

## Trạng thái tổng quan

| Giai đoạn | Trạng thái | Ghi chú |
|---|---|---|
| 1. Foundation | ✅ Hoàn thành | 25 tool, install/uninstall/outdated |
| 2. Refactor & Bug Fixes | ✅ Hoàn thành | Escaping fix, dedup, consolidation |
| 3. Reliability & Security | 🔲 Chưa bắt đầu | Checksum, retry, dry-run |
| 4. Version Management | 🔲 Chưa bắt đầu | upgrade, list, pin, state |
| 5. Tool Coverage | 🔲 Chưa bắt đầu | helm, skopeo, syft, cosign, ... |
| 6. UX & Interactive | 🔲 Chưa bắt đầu | gum integration, completion |
| 7. CI/CD & Distribution | 🔲 Chưa bắt đầu | Automated testing, install script |
