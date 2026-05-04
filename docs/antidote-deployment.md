# Triển khai Antidote — Zsh Plugin Manager

- **Ngày**: 2026-05-04
- **Owner**: ttungbmt
- **Scope**: Cài đặt + cấu hình `antidote` trên Linux (Oracle Linux 9, Ubuntu 22.04+) cho workflow DevOps/Platform Engineer
- **Tình trạng**: Hướng dẫn triển khai, có đề xuất tích hợp vào os-scripts CLI

## 1. Antidote là gì?

`antidote` là zsh plugin manager thế hệ 2 (kế nhiệm `antibody`), do **Mads Hartmann** & cộng đồng phát triển (`mattmc3/antidote`). Đặc điểm:

| Thuộc tính | Mô tả |
|---|---|
| Ngôn ngữ | 100% zsh thuần (không phụ thuộc Go/Ruby như antibody/antigen) |
| Hiệu năng | "Static loading" — sinh sẵn `.zsh_plugins.zsh` lúc đầu shell, không clone runtime |
| Cú pháp | Plugin file dạng `~/.zsh_plugins.txt` (1 dòng = 1 plugin) |
| Tương thích | Chạy được với `zinit`, `zgenom`, `antigen` syntax thông qua wrapper |
| License | MIT |

**Tại sao chọn antidote?**

1. **Tốc độ shell start-up**: static loading cache 1 lần → khởi động zsh < 50ms ngay cả với 30+ plugins.
2. **Đơn giản**: chỉ cần file text `~/.zsh_plugins.txt`, không cần DSL phức tạp.
3. **Reproducible**: commit file plugin list vào dotfiles repo → đồng bộ giữa máy.
4. **Active maintenance**: antibody bị deprecate, antidote là replacement chính thức được tác giả khuyến nghị.

## 2. Yêu cầu hệ thống

| Thành phần | Phiên bản tối thiểu | Ghi chú |
|---|---|---|
| `zsh` | ≥ 5.4 | Khuyến nghị 5.8+. Đã có module `./cli install zsh` (zsh-bin 5.8). |
| `git` | ≥ 2.0 | Để clone plugins. |
| `curl` | bất kỳ | Tải installer / antidote source. |
| Disk | ~50MB | Cho `~/.cache/antidote` + plugin clones. |

Kiểm tra trước:

```bash
zsh --version
git --version
curl --version
echo "$SHELL"   # nên là /usr/local/bin/zsh sau khi cài zsh
```

## 3. Phương pháp cài đặt

Có 4 phương pháp, ưu tiên giảm dần. Trên os-scripts khuyến nghị **Phương pháp A** (clone Git) vì đơn giản, không phụ thuộc package manager.

### 3.1 Phương pháp A — Clone Git (khuyến nghị)

Đây là phương pháp chính thức, hoạt động trên mọi Linux distro.

```bash
# System-wide (cần sudo) — dùng cho server multi-user
sudo git clone --depth=1 https://github.com/mattmc3/antidote.git \
  /usr/local/share/antidote

# Hoặc per-user — dùng cho workstation cá nhân
git clone --depth=1 https://github.com/mattmc3/antidote.git \
  ${ZDOTDIR:-$HOME}/.antidote
```

**Pin version** (production):

```bash
ANTIDOTE_VERSION="v1.9.7"
sudo git clone --depth=1 --branch "$ANTIDOTE_VERSION" \
  https://github.com/mattmc3/antidote.git /usr/local/share/antidote
```

Kiểm tra latest tag:

```bash
curl -fsSL https://api.github.com/repos/mattmc3/antidote/releases/latest \
  | grep '"tag_name"' | cut -d'"' -f4
```

### 3.2 Phương pháp B — Homebrew (macOS / Linuxbrew)

```bash
brew install antidote
```

Lưu ý: Linuxbrew cài vào `/home/linuxbrew/.linuxbrew/share/antidote`.

### 3.3 Phương pháp C — Oh-My-Zsh custom plugin

Nếu đã dùng OMZ (không khuyến nghị vì làm chậm shell):

```bash
git clone --depth=1 https://github.com/mattmc3/antidote.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/antidote
```

Sau đó thêm `antidote` vào `plugins=(...)` trong `~/.zshrc`.

### 3.4 Phương pháp D — Package manager (apt/dnf)

Hiện tại **không có** package chính thức cho `apt` hoặc `dnf`. Có thể chạy `apt search antidote` / `dnf search antidote` để xác nhận. Nếu cần distro package, dùng phương pháp A.

## 4. Cấu hình `~/.zshrc`

Sau khi cài, thêm 2 phần vào `~/.zshrc`:

### 4.1 Phần khởi động antidote (đặt sớm trong file)

```zsh
# --- antidote bootstrap ---
# 1. Source antidote
if [[ -f /usr/local/share/antidote/antidote.zsh ]]; then
  source /usr/local/share/antidote/antidote.zsh
elif [[ -f ${ZDOTDIR:-$HOME}/.antidote/antidote.zsh ]]; then
  source ${ZDOTDIR:-$HOME}/.antidote/antidote.zsh
else
  echo "antidote not found — install via os-scripts: ./cli install antidote" >&2
fi

# 2. Plugin file location
zsh_plugins=${ZDOTDIR:-$HOME}/.zsh_plugins.txt

# 3. Tạo plugin file rỗng nếu chưa tồn tại
[[ -f $zsh_plugins ]] || touch $zsh_plugins

# 4. Static loading (sinh .zsh_plugins.zsh nếu chưa có / đã cũ hơn .txt)
if [[ ! $zsh_plugins.zsh -nt $zsh_plugins ]]; then
  antidote bundle <$zsh_plugins >$zsh_plugins.zsh
fi

# 5. Source kết quả static
source $zsh_plugins.zsh
unset zsh_plugins
```

**Giải thích flow**:
- Bước 1: source thư viện antidote vào shell.
- Bước 4: so sánh `.zsh_plugins.txt` (input) với `.zsh_plugins.zsh` (output cache). Nếu input mới hơn output (vừa edit), regenerate cache.
- Bước 5: source cache duy nhất → mọi plugin hoạt động ngay, không clone runtime.

### 4.2 Phần dynamic mode (tùy chọn — chậm hơn)

Nếu muốn `antidote load` runtime thay vì static cache (cho debug):

```zsh
source /usr/local/share/antidote/antidote.zsh
antidote load   # đọc trực tiếp ~/.zsh_plugins.txt mỗi lần
```

> **Khuyến nghị production**: dùng static loading (4.1). Dynamic chỉ dùng khi đang thử plugins mới.

## 5. File `~/.zsh_plugins.txt`

Cú pháp: 1 dòng = 1 plugin theo format `<owner>/<repo>` (GitHub) hoặc URL Git đầy đủ.

### 5.1 Bộ plugins khuyến nghị cho DevOps

```text
# === Performance ===
romkatv/powerlevel10k                         # prompt nhanh nhất hiện nay (alternative cho starship)

# === Completion & syntax ===
zsh-users/zsh-completions
zsh-users/zsh-autosuggestions                 # gợi ý lịch sử
zsh-users/zsh-syntax-highlighting             # highlight cú pháp inline
zsh-users/zsh-history-substring-search        # ↑↓ search history

# === Oh-My-Zsh libs (chọn lọc, không nạp toàn bộ OMZ) ===
ohmyzsh/ohmyzsh path:lib/clipboard.zsh
ohmyzsh/ohmyzsh path:lib/history.zsh
ohmyzsh/ohmyzsh path:lib/key-bindings.zsh

# === DevOps plugins ===
ohmyzsh/ohmyzsh path:plugins/git
ohmyzsh/ohmyzsh path:plugins/kubectl
ohmyzsh/ohmyzsh path:plugins/docker
ohmyzsh/ohmyzsh path:plugins/helm
ohmyzsh/ohmyzsh path:plugins/terraform
ohmyzsh/ohmyzsh path:plugins/aws
ohmyzsh/ohmyzsh path:plugins/gcloud

# === Tools tích hợp ===
ajeetdsouza/zoxide                            # cd thông minh (z command)
Aloxaf/fzf-tab                                # fzf cho tab completion (load CUỐI cùng)
```

### 5.2 Annotation đặc biệt

| Annotation | Tác dụng |
|---|---|
| `path:<dir>` | Chỉ load file cụ thể trong repo (vd. `path:plugins/git`) |
| `kind:fpath` | Thêm vào `$fpath` thay vì source |
| `kind:zsh` | Source mọi `.zsh` trong repo (mặc định) |
| `branch:<name>` | Checkout branch khác `master` |
| `conditional:<expr>` | Chỉ load khi expr trả về 0 (vd. `conditional:[[ $OSTYPE == darwin* ]]`) |

Ví dụ điều kiện OS:

```text
ohmyzsh/ohmyzsh path:plugins/macos conditional:[[ $OSTYPE == darwin* ]]
ohmyzsh/ohmyzsh path:plugins/systemd conditional:[[ $OSTYPE == linux* ]]
```

### 5.3 Thứ tự load quan trọng

Một số plugin có ràng buộc về thứ tự — phải khai báo đúng trật tự:

1. `zsh-users/zsh-completions` — đầu tiên (đăng ký completions)
2. `ohmyzsh/ohmyzsh path:lib/*` — libs gốc
3. `ohmyzsh/ohmyzsh path:plugins/*` — plugins thường
4. `Aloxaf/fzf-tab` — **trước** `zsh-syntax-highlighting`
5. `zsh-users/zsh-syntax-highlighting` — gần cuối
6. `zsh-users/zsh-autosuggestions` — **cuối cùng**
7. `zsh-users/zsh-history-substring-search` — sau `zsh-syntax-highlighting`

## 6. Quản lý plugin lifecycle

### 6.1 Thêm plugin mới

```bash
# 1. Edit file
echo "owner/new-plugin" >> ~/.zsh_plugins.txt

# 2. Force regenerate cache
antidote bundle <~/.zsh_plugins.txt >~/.zsh_plugins.zsh

# 3. Reload shell
exec zsh
```

### 6.2 Cập nhật tất cả plugins

```bash
antidote update
```

Lệnh này `git pull` mọi plugin trong cache (`~/.cache/antidote`).

### 6.3 Xóa plugin

```bash
# 1. Xóa dòng trong ~/.zsh_plugins.txt (dùng sed hoặc editor)
sed -i '/owner\/old-plugin/d' ~/.zsh_plugins.txt

# 2. Regenerate
antidote bundle <~/.zsh_plugins.txt >~/.zsh_plugins.zsh

# 3. Cleanup cache (tùy chọn — xóa repo đã clone)
antidote purge owner/old-plugin
```

### 6.4 Liệt kê plugins đang dùng

```bash
antidote list                    # full path
antidote list --short            # owner/repo only
```

### 6.5 Kiểm tra phiên bản antidote

```bash
antidote --version
antidote home                    # in path đến antidote
```

## 7. Tích hợp vào os-scripts CLI (đề xuất)

Hiện tại `./cli install zsh` cài zsh-bin. Đề xuất thêm `./cli install antidote` để hoàn thiện stack shell.

### 7.1 Thay đổi `src/bashly.yml`

Thêm vào nhóm `install` và `uninstall`:

```yaml
# install group
- name: antidote
  help: Install antidote zsh plugin manager
  flags:
  - long: --version
    short: -v
    arg: version
    help: antidote version (e.g., v1.9.7 or latest)
    default: latest
  - long: --force
    short: -f
    help: Force overwrite if antidote is already installed
  - long: --prefix
    arg: prefix
    help: Install prefix
    default: /usr/local/share/antidote

# uninstall group
- name: antidote
  help: Uninstall antidote
```

### 7.2 `src/commands/install/antidote.sh`

```bash
version=${args[--version]}
force=${args[--force]}
prefix=${args[--prefix]}
name="antidote"
target="${prefix}/antidote.zsh"

# --- Step 1: Guard against overwrite ---
guard_existing "$name" "$target" "$force"

echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

# --- Step 2: Resolve version ---
if [[ "$version" == "latest" ]]; then
  version=$(github_latest_tag "mattmc3/antidote")
fi

# --- Step 3: Clone repo (shallow) ---
if [ -d "$prefix" ]; then
  sudo rm -rf "$prefix"
fi

if sudo git clone --depth=1 --branch "$version" \
   https://github.com/mattmc3/antidote.git "$prefix"; then
  echo "$(green_bold ✓) $name installed at $(bold "$prefix") ($(bold "$version"))"
  echo ""
  echo "Next steps:"
  echo "  1. Add to ~/.zshrc:"
  echo "       source ${prefix}/antidote.zsh"
  echo "  2. Create ~/.zsh_plugins.txt with desired plugins"
  echo "  3. See: docs/antidote-deployment.md"
else
  echo "$(red ✗ Failed to install $name.)"
  exit 1
fi
```

### 7.3 `src/commands/uninstall/antidote.sh`

```bash
prefix="/usr/local/share/antidote"
name="antidote"

if [ -d "$prefix" ]; then
  echo "Removing $(cyan_bold "$name") from $(bold "$prefix")..."
  sudo rm -rf "$prefix"
  echo "$(green_bold ✓) $name uninstalled."
  echo ""
  echo "Cleanup hint: also remove the antidote source block from ~/.zshrc"
  echo "and ~/.zsh_plugins.{txt,zsh} if no longer needed."
else
  echo "$(yellow "$name") is not installed at $(bold "$prefix")."
fi
```

### 7.4 `src/lib/registry/antidote.sh`

```bash
ANTIDOTE_GITHUB_REPO="mattmc3/antidote"

antidote_fetch_local_version() {
  local target="$1"
  # target = /usr/local/share/antidote/antidote.zsh → repo dir = dirname
  local repo_dir
  repo_dir=$(dirname "$target")
  if [ -d "$repo_dir/.git" ]; then
    git -C "$repo_dir" describe --tags --abbrev=0 2>/dev/null | tr -d 'v\r\n'
  fi
}
```

### 7.5 Roadmap tích hợp

1. PR thêm 3 file trên + entry trong `bashly.yml`.
2. Chạy `bashly generate` → kiểm tra `./cli install antidote --help`.
3. Test fresh install + force overwrite + uninstall.
4. Update `TOOLS.md` thêm row antidote vào nhóm "Shell".
5. Cân nhắc preset `presets/devbox.yml` thêm `tools/antidote` + tự seed `~/.zsh_plugins.txt`.

## 8. Troubleshooting

### 8.1 `antidote: command not found`

**Nguyên nhân**: chưa source file `antidote.zsh` trong `~/.zshrc`.

**Fix**: thêm dòng source ở mục 4.1, restart shell `exec zsh`.

### 8.2 Shell start chậm sau khi thêm plugins

**Chẩn đoán**:

```bash
zsh -i -c 'zmodload zsh/zprof; source ~/.zshrc; zprof' | head -30
```

**Nguyên nhân thường gặp**:
- Đang dùng `antidote load` thay vì static loading → đổi sang flow ở 4.1.
- Plugin nặng như `oh-my-zsh` toàn bộ → chỉ load `path:plugins/<name>` cụ thể.
- File cache `.zsh_plugins.zsh` bị xóa → mỗi lần shell start phải regenerate.

### 8.3 Plugin không load sau khi thêm vào `.zsh_plugins.txt`

```bash
# Force regenerate cache
antidote bundle <~/.zsh_plugins.txt >~/.zsh_plugins.zsh
exec zsh
```

Nếu vẫn lỗi, xóa cache antidote:

```bash
rm -rf ~/.cache/antidote
antidote bundle <~/.zsh_plugins.txt >~/.zsh_plugins.zsh
```

### 8.4 GitHub rate-limit khi `antidote update`

```bash
# Set GH_TOKEN trong môi trường
export GH_TOKEN="ghp_xxx"
antidote update
```

Hoặc dùng SSH thay vì HTTPS bằng cách đổi format trong `.zsh_plugins.txt`:

```text
git@github.com:owner/repo.git
```

### 8.5 Conflict với `oh-my-zsh` cũ

Nếu trước đó dùng OMZ, cần tắt phần load OMZ trong `~/.zshrc`:

```bash
# Comment out:
# export ZSH="$HOME/.oh-my-zsh"
# source $ZSH/oh-my-zsh.sh
```

Rồi chuyển từng plugin OMZ sang format `ohmyzsh/ohmyzsh path:plugins/<name>` trong `.zsh_plugins.txt`.

### 8.6 Permission denied khi clone vào `/usr/local/share/antidote`

Cần `sudo` cho system-wide install. Nếu không có sudo, chuyển sang per-user (`~/.antidote`).

## 9. Bảo mật & best practices

| Khuyến nghị | Lý do |
|---|---|
| Pin version (`--branch v1.9.7`) trên server production | Tránh breaking change từ master |
| Chỉ load plugin từ owner đáng tin cậy (`zsh-users`, `ohmyzsh`, `mattmc3`) | Plugin code chạy trong shell session — có quyền user |
| Commit `~/.zsh_plugins.txt` vào dotfiles repo | Reproducible giữa các máy |
| Chạy `antidote update` định kỳ (vd. weekly cron) | Nhận security patches plugin |
| Không dùng `eval` trong plugins lạ | Risk arbitrary code execution |
| Backup `~/.zsh_plugins.zsh` trước upgrade lớn | Rollback nhanh nếu shell hỏng |

## 10. Tham khảo

- Repo chính thức: <https://github.com/mattmc3/antidote>
- Tài liệu: <https://getantidote.github.io/>
- Migration từ antibody: <https://getantidote.github.io/migrating-from-antibody>
- So sánh plugin manager: <https://getantidote.github.io/plugin-managers>
- File `src/commands/install/zsh.sh` (os-scripts) — tham khảo pattern install zsh-bin
- Spec gốc: `docs/superpowers/specs/2026-05-04-os-scripts-architecture-design.md`

## 11. Checklist triển khai

- [ ] `zsh --version` ≥ 5.4 (chạy `./cli install zsh` nếu chưa có)
- [ ] Cài antidote theo phương pháp A (clone Git, pin version)
- [ ] Thêm bootstrap block vào `~/.zshrc` (mục 4.1)
- [ ] Tạo `~/.zsh_plugins.txt` với bộ plugin khuyến nghị (mục 5.1)
- [ ] Chạy `exec zsh`, kiểm tra start-up time `time zsh -ic exit` < 200ms
- [ ] Verify: `antidote list --short` liệt kê đủ plugins
- [ ] Backup `~/.zshrc`, `~/.zsh_plugins.txt` vào dotfiles repo
- [ ] (Tùy chọn) PR tích hợp `./cli install antidote` vào os-scripts (mục 7)
