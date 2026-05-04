# 🚀 The Ultimate Modern DevOps & SysAdmin Toolstack

*(🌟: Các công cụ cốt lõi đề xuất bổ sung thêm để bộ đồ nghề hoàn thiện 100% cho thực chiến).*

### 💻 1. Terminal, Shell & Dotfiles
| STT | Nhóm tính năng | Công cụ (Ưu tiên > Bổ trợ) | Chức năng & Ghi chú thực chiến |
|:---:|:---|:---|:---|
| 1 | **Multiplexer** | **`zellij > tmux`** | Trình quản lý đa cửa sổ. `zellij` cho local (UI xịn), nhưng buộc phải thạo `tmux` vì là tiêu chuẩn trên server. |
| 2 | **Shell & Plugin** | **`zsh`**, **`zinit`** | Zsh shell kết hợp trình quản lý plugin siêu tốc `zinit`. |
| 3 | **Prompt** | **`starship`** | Dấu nhắc lệnh cross-shell hiển thị trạng thái Git/K8s/Cloud siêu nhanh. |
| 4 | **Version & Env** | **`mise > direnv`** | Quản lý version (Node, Python...) và tự động load biến môi trường theo project. |
| 5 | **Dotfiles** | **`chezmoi`** | Quản lý file cấu hình cá nhân đa nền tảng, hỗ trợ mã hoá bảo mật. |
| 6 | **Lịch sử lệnh** | **`atuin`** | Đồng bộ và tìm kiếm lịch sử lệnh thông minh bằng SQLite (thay `Ctrl+R`). |
| 7 | **Tiện ích Shell** | **`aliasman`**, **`thefuck`** | Quản lý alias (`aliasman`), tự sửa lỗi gõ sai lệnh thần thánh (`thefuck`). |
| [x] | **System Info** | **`fastfetch`** | Xem thông tin hệ thống (OS, RAM, Kernel) dạng ASCII art siêu tốc. |

### 🗂️ 2. Core CLI & Quản lý File (Modern Coreutils)
| STT | Nhóm tính năng | Công cụ (Ưu tiên > Bổ trợ) | Chức năng & Ghi chú thực chiến |
|:---:|:---|:---|:---|
| 1 | **Liệt kê file** | **`eza > lsd`** | Liệt kê file có icon/màu sắc (thay `ls`). Cộng đồng hiện chuộng `eza` hơn. |
| 2 | **Đọc nội dung** | **`bat`** | Xem file có highlight cú pháp và Git diff (thay `cat`). |
| 3 | **Chuyển thư mục** | **`zoxide`** | Nhảy thư mục thông minh, tự học thói quen người dùng (thay `cd`). |
| 4 | **TUI File Manager**| **`yazi`** | Quản lý file dạng giao diện Terminal, mượt, preview được ảnh/text. |
| 5 | **Tìm kiếm file** | **`fd`** | Tìm kiếm tên file tốc độ cao, cú pháp thân thiện (thay `find`). |
| 6 | **Tìm kiếm nội dung**| **`ripgrep`** | Tìm chuỗi text bên trong file với tốc độ "bàn thờ" (thay `grep`). |
| 7 | **Tìm kiếm mờ** | **`fzf`** | Fuzzy finder đa năng, trái tim kết nối mọi thao tác trên Terminal. |
| 8 | **Dung lượng đĩa** | **`ncdu > duf`** | Phân tích thư mục chiếm dung lượng (`ncdu`) > Xem tổng quan ổ cứng cực đẹp (`duf`). |
| 9 | **Hướng dẫn lệnh** | **`tldr`** | Xem hướng dẫn lệnh (manpage) bản rút gọn kèm ví dụ thực tế. |

### 📝 3. Text Processing, Code & Scripting
| STT | Nhóm tính năng | Công cụ (Ưu tiên > Bổ trợ) | Chức năng & Ghi chú thực chiến |
|:---:|:---|:---|:---|
| 1 | **Text Editor** | **`lazyvim`** | Cấu hình Neovim biến terminal thành IDE thực thụ, siêu tối ưu tốc độ gõ. |
| 2 | **Data Parsers** | 🌟 **`yq > jq`** | Parse và filter cấu hình YAML (`yq`) và JSON (`jq`). *YAML là xương sống của DevOps nên `yq` là bắt buộc.* |
| 3 | **Scripting UI** | **`gum`** | Công cụ tạo giao diện tương tác (dropdown, spin, input) cực đẹp cho bash script. |
| 4 | **Ngôn ngữ** | **`python3`** | Ngôn ngữ đa năng để tự động hoá và xử lý logic phức tạp. |
| 5 | **Database CLI** | **`supabase`** | CLI thao tác Database/Backend đặc thù cho nền tảng Supabase. |

### 🚀 4. Task Runners, Git & CI/CD Workflow
| STT | Nhóm tính năng | Công cụ (Ưu tiên > Bổ trợ) | Chức năng & Ghi chú thực chiến |
|:---:|:---|:---|:---|
| 1 | **Git Workflow** | **`lazygit > gh > git`** | TUI giải quyết conflict cực nhàn (`lazygit`) > GitHub CLI (`gh`) > Git gốc (`git`). |
| 2 | **Git Diff** | **`delta`** | Định dạng output của `git diff` đẹp như VSCode, highlight từng từ thay đổi. |
| 3 | **Task Runners** | **`taskfile > just > make`**| Project lớn (`taskfile`) > Project cá nhân (`just`) > Chuẩn chung open-source (`make`). |
| 4 | **Auto Reload** | **`watchexec`** | Lắng nghe thay đổi file để tự động chạy lại lệnh/script. |
| 5 | **Local CI/CD** | 🌟 **`act`** | Chạy GitHub Actions trực tiếp trên máy local bằng Docker, tránh push commit rác để test pipeline. |

### 🐳 5. Containers (Docker) Ecosystem
| STT | Nhóm tính năng | Công cụ (Ưu tiên > Bổ trợ) | Chức năng & Ghi chú thực chiến |
|:---:|:---|:---|:---|
| 1 | **Container Mgmt** | **`lazydocker > nerdctl`**| TUI quản lý trực quan (`lazydocker`) > CLI tương thích Docker cho môi trường containerd (`nerdctl`). |
| 2 | **Image Analyzer**| 🌟 **`dive`** | Soi chi tiết từng layer của Docker image để tìm nguyên nhân gây phình to dung lượng. |
| 3 | **Registry Utils**| 🌟 **`skopeo`** | Inspect/copy image trực tiếp giữa các Registry (VD: Dockerhub sang AWS ECR) không cần `docker pull`. |

### ☸️ 6. Kubernetes Ecosystem
| STT | Nhóm tính năng | Công cụ (Ưu tiên > Bổ trợ) | Chức năng & Ghi chú thực chiến |
|:---:|:---|:---|:---|
| 1 | **Cluster Mgmt** | **`k9s > kubectl`** | Quản trị Cluster bằng TUI thần thánh (`k9s`) > CLI gốc chuẩn mực (`kubectl`). |
| 2 | **Context & NS** | 🌟 **`kubectx > kubens`** | Cặp bài trùng: Chuyển đổi Cluster (`kubectx`) và Namespaces (`kubens`) qua lại siêu tốc. |
| 3 | **Deployment** | **`helmfile > helm`** | Khai báo triển khai nhiều app K8s chuẩn IaC (`helmfile`) > Package manager (`helm`). |
| 4 | **Logs & Output** | 🌟 **`stern`**, **`kubecolor`**| Tail log nhiều Pods cùng lúc có màu sắc (`stern`). Tô màu output lệnh K8s (`kubecolor`). |
| 5 | **Auditing** | **`popeye`** | Scan báo cáo sức khoẻ, tìm misconfiguration và tài nguyên mồ côi trong Cluster. |
| 6 | **Provisioning** | **`kops`** | Cài đặt và quản lý K8s Cluster (Control Plane & Worker) chuẩn Production. |

### ☁️ 7. Infrastructure as Code (IaC) & Cloud
| STT | Nhóm tính năng | Công cụ (Ưu tiên > Bổ trợ) | Chức năng & Ghi chú thực chiến |
|:---:|:---|:---|:---|
| 1 | **Provisioning** | 🌟 **`terraform`** | Cấp phát hạ tầng bằng Code. Xương sống của DevOps hiện đại. |
| 2 | **IaC Wrapper** | 🌟 **`terragrunt`** | Bọc ngoài Terraform giúp code DRY (không lặp lại) khi có nhiều môi trường Dev/Stg/Prod. |
| 3 | **Config Mgmt** | **`ansible`** | Cấu hình tự động hàng loạt máy chủ (VMs, Bare-metal), không cần cài agent. |
| 4 | **Cloud CLI** | 🌟 **`aws-cli`** | Giao tiếp với Cloud Provider công ty dùng (Tương tự `gcloud` hoặc `az`). |
| 5 | **Cloud Access** | 🌟 **`granted > aws-vault`**| Quản lý credential và SSO (Assume Role) an toàn khi thao tác với nhiều tài khoản Cloud. |

### 🌐 8. Networking & Observability
| STT | Nhóm tính năng | Công cụ (Ưu tiên > Bổ trợ) | Chức năng & Ghi chú thực chiến |
|:---:|:---|:---|:---|
| 1 | **System Monitor**| **`bottom`** (`btm`) | Giám sát CPU, RAM, Network dạng đồ thị cực mượt (thay thế `htop`). |
| 2 | **Log Viewer** | **`lnav`** | Trình đọc log cao cấp, merge log, parse format và truy vấn bằng cú pháp SQL. |
| 3 | **Network Diag** | **`trippy > gping`** | Phân tích ping/MTR cực chi tiết (`trippy`) > Ping dạng đồ thị (`gping`). |
| 4 | **DNS Lookup** | **`doggo`** | Tra cứu DNS hiển thị nhiều màu sắc, cực kỳ dễ đọc (thay thế `dig/nslookup`). |
| 5 | **Packet Analyzer**| 🌟 **`termshark`** | Bản TUI của Wireshark. Phân tích gói tin (`tcpdump`) trực quan ngay trên terminal server. |
| 6 | **HTTP & API** | **`httpie`** | Gọi API HTTP với cú pháp ngắn gọn, tự động format JSON (thay thế `curl`). |
| 7 | **Watch & Diff** | **`viddy`** | Chạy lại lệnh định kỳ, bôi màu sự thay đổi, hỗ trợ lùi thời gian (thay thế `watch`). |
| 8 | **Load Testing** | 🌟 **`k6 > hey`** | Bắn tải test API bằng script JS cực mạnh (`k6`) > Test nhanh API HTTP (`hey`). |
| 9 | **Benchmarking** | **`hyperfine`** | Đo đạc và so sánh tốc độ thực thi hiệu năng của các lệnh CLI / script. |

### 🔒 9. Security & Secrets Management
| STT | Nhóm tính năng | Công cụ (Ưu tiên > Bổ trợ) | Chức năng & Ghi chú thực chiến |
|:---:|:---|:---|:---|
| 1 | **Secrets Vault** | 🌟 **`vault`** | Quản lý secret/credential tập trung (HashiCorp), tiêu chuẩn doanh nghiệp lớn. |
| 2 | **File Encryption**| **`sops > age`** | Mã hoá file cấu hình (YAML/JSON) chứa mật khẩu để tự tin đẩy lên Git an toàn. |
| 3 | **Vulnerabilities**| **`trivy`** | Quét lỗ hổng (CVE) toàn diện cho Docker Image, OS Packages và Repo. |
| 4 | **Secret Scanner** | **`gitleaks`** | Dò quét tự động ngăn chặn dev commit nhầm Password/API Key lên Github. |
| 5 | **Cert Mgmt** | 🌟 **`step`** | Công cụ quản lý chứng chỉ SSL/TLS, JWT hiện đại, dễ thao tác hơn `openssl` rất nhiều. |
| 6 | **Port Scanner** | 🌟 **`rustscan`** | Quét toàn bộ port hệ thống cực tốc (vài giây), tự động pipe sang Nmap để phân tích sâu. |

### 🤖 10. AI CLI (LLMs in Terminal)
| STT | Nhóm tính năng | Công cụ (Ưu tiên > Bổ trợ) | Chức năng & Ghi chú thực chiến |
|:---:|:---|:---|:---|
| 1 | **AI Assistants** | 🌟 **`aichat > claude > gemini`**| `aichat` làm cổng quản lý đa model, tối ưu việc pipe dữ liệu (VD: `cat log \| aichat "Fix lỗi"`). |
| 2 | **Local LLM** | **`ollama`** | Chạy model AI cục bộ (Offline), đảm bảo 100% bảo mật dữ liệu riêng tư của công ty. |