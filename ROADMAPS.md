# Roadmap cho OS-Scripts CLI

Dự án `os-scripts` đang trong quá trình chuyển đổi từ các script rời rạc sang một công cụ dòng lệnh (CLI) thống nhất, chuyên nghiệp và mạnh mẽ dựa trên `bashly`. Dưới đây là lộ trình (roadmap) đề xuất để phát triển dự án này:

## Giai đoạn 1: Xây dựng nền tảng (Foundation) - *Đang thực hiện*
**Mục tiêu:** Thiết lập khung sườn CLI cơ bản và di chuyển các tác vụ cài đặt công cụ thiết yếu.
- [x] Khởi tạo dự án với `bashly` (lệnh `./cli`).
- [x] Thêm lệnh `install kustomize` (hỗ trợ chọn phiên bản, progress bar an toàn).
- [x] Thêm lệnh `uninstall kustomize`.
- [ ] Bổ sung các lệnh cài đặt/gỡ cài đặt cho các công cụ khác đã có trong dự án (ví dụ: `sops`, `ksops`, `helm`, `kubectl`).
- [x] Chuẩn hóa cơ cấu thư mục mã nguồn (`src/`) theo chuẩn Bashly.

## Giai đoạn 2: Chuẩn hóa & Tái cấu trúc thư viện (Standardization & Refactoring)
**Mục tiêu:** Tái sử dụng và nâng cấp các thư viện cũ nằm trong `.archived/lib/`.
- [ ] **Logging & Output:** Chuyển đổi `lib/log.sh` và tích hợp các thư viện màu sắc (`bash-colors`) để log ra terminal có cấu trúc (INFO, WARN, ERROR, SUCCESS).
- [ ] **OS Utilities:** Chuyển đổi `lib/os.sh` để hỗ trợ đa hệ điều hành (Ubuntu, CentOS/Oracle Linux) trong việc cài đặt package.
- [ ] **GitHub API:** Chuyển đổi `lib/github.sh` thành các hàm dùng chung (shared partials) trong bashly để fetch releases, tags cho mọi lệnh cài đặt.
- [ ] Loại bỏ code lặp lại (DRY) trong các script cài đặt (tạo hàm tải xuống chung `download_github_release`).

## Giai đoạn 3: Nâng cấp trải nghiệm tương tác (Interactive UX)
**Mục tiêu:** Tích hợp các thư viện UI hiện đại (như [charmbracelet/gum](https://github.com/charmbracelet/gum)) được tham chiếu trong README.
- [ ] **Interactive Prompts:** Sử dụng `gum choose` để cho phép người dùng chọn phiên bản công cụ bằng phím mũi tên thay vì phải gõ cờ `--version`.
- [ ] **Xác nhận an toàn:** Dùng `gum confirm` để hỏi người dùng trước khi thực hiện các tác vụ nguy hiểm (như `uninstall` hay `upgrade` OS).
- [ ] **Spinners & Progress:** Thay thế curl progress bar bằng `gum spin` cho các tiến trình tải xuống hoặc chờ đợi hệ thống (chờ node RKE2 Ready).

## Giai đoạn 4: Tích hợp vận hành DevOps & Kubernetes (Advanced Operations)
**Mục tiêu:** Mang các playbook Ansible và script vận hành thực tế vào trong CLI để chạy một cách tự động.
- [ ] **RKE2 Operations:** Thêm nhóm lệnh `cli rke2 snapshot`, `cli rke2 upgrade`, `cli rke2 status`.
- [ ] **OS Management:** Thêm lệnh `cli os upgrade` để đóng gói luồng nâng cấp hệ điều hành (như tác vụ Oracle Linux Upgrade).
- [ ] **Storage & Backup:** Tích hợp kiểm tra sức khỏe và quản lý Rook-Ceph (`cli storage check`, `cli storage recover`).
