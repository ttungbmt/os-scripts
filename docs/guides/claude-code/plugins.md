# Claude Code Plugins — Cheatsheet

> Quản lý plugins qua CLI (`claude plugin`) hoặc slash command (`/plugin`).
> Updated May 2026 | Claude Code v2.1.128+

---

## Install

```bash
# Cú pháp: claude plugin install <name>@<marketplace>
claude plugin install github@claude-plugins-official
claude plugin install my-tool@my-marketplace

# Chỉ định scope (mặc định: user)
claude plugin install github@claude-plugins-official --scope user     # Mọi project
claude plugin install github@claude-plugins-official --scope project  # Project hiện tại (committed)
claude plugin install github@claude-plugins-official --scope local    # Project hiện tại (gitignored)

# Load tạm thời cho session (không lưu)
claude --plugin-dir ./my-plugin
claude --plugin-url https://example.com/plugin.zip
claude --plugin-dir ./plugin-a --plugin-dir ./plugin-b   # Nhiều plugin
```

---

## View & List

```bash
# Liệt kê plugin đã cài
claude plugin list

# Output dạng JSON
claude plugin list --json

# Hiện cả plugin có sẵn từ marketplace
claude plugin list --json --available

# Slash command — mở UI quản lý
/plugin
```

**UI `/plugin` gồm 4 tab:**

| Tab | Mô tả |
|-----|-------|
| **Discover** | Duyệt plugin từ marketplace |
| **Installed** | Xem và quản lý plugin đã cài |
| **Marketplaces** | Thêm/xóa/cập nhật marketplace |
| **Errors** | Xem lỗi load plugin |

---

## Enable / Disable

```bash
# Tắt plugin (giữ nguyên, không xóa)
claude plugin disable github@claude-plugins-official
claude plugin disable github@claude-plugins-official --scope project

# Bật lại plugin đã tắt
claude plugin enable github@claude-plugins-official
claude plugin enable github@claude-plugins-official --scope project
```

---

## Update

```bash
# Cập nhật lên phiên bản mới nhất
claude plugin update github@claude-plugins-official
claude plugin update github@claude-plugins-official --scope project

# Reload plugin không cần restart session
/reload-plugins
```

---

## Uninstall

```bash
# Các cách viết tương đương
claude plugin uninstall github@claude-plugins-official
claude plugin remove   github@claude-plugins-official
claude plugin rm       github@claude-plugins-official

# Chỉ định scope
claude plugin rm github@claude-plugins-official --scope project

# Giữ lại data của plugin
claude plugin rm github@claude-plugins-official --keep-data

# Xóa luôn dependency không còn dùng
claude plugin rm github@claude-plugins-official --prune

# Bỏ qua confirm (dùng trong script/CI)
claude plugin rm github@claude-plugins-official -y

# Xóa các dependency thừa (không plugin nào dùng)
claude plugin prune
claude plugin prune --dry-run         # Xem trước, không xóa
claude plugin prune --scope project
claude plugin prune -y
```

---

## Marketplace

```bash
# Thêm marketplace
claude plugin marketplace add owner/repo                         # GitHub
claude plugin marketplace add https://gitlab.com/org/repo.git   # Git URL
claude plugin marketplace add git@gitlab.com:org/repo.git       # Git SSH
claude plugin marketplace add https://example.com/marketplace.json  # Remote JSON
claude plugin marketplace add ./local/marketplace.json           # Local file

# Thêm theo branch/tag
claude plugin marketplace add https://gitlab.com/org/repo.git#v1.0.0

# Liệt kê marketplace đã thêm
claude plugin marketplace list

# Cập nhật marketplace
claude plugin marketplace update my-marketplace

# Xóa marketplace
claude plugin marketplace remove my-marketplace

# Shortcut: "market" thay cho "marketplace"
claude plugin market list
claude plugin market add owner/repo
```

### Slash command tương đương

```bash
/plugin marketplace add <source>
/plugin marketplace list
/plugin marketplace update <name>
/plugin marketplace remove <name>

# Hoặc viết tắt
/plugin market add <source>
```

---

## Validate & Debug

```bash
# Kiểm tra plugin.json có hợp lệ không (chạy trong thư mục plugin)
claude plugin validate
/plugin validate

# Tạo release tag (chạy trong thư mục plugin)
claude plugin tag
claude plugin tag --push          # Push tag lên remote luôn
claude plugin tag --dry-run       # Xem trước, không tạo
claude plugin tag --force         # Tạo dù working tree dirty

# Debug: xem chi tiết load plugin
claude --debug
```

---

## Scopes

| Scope | Settings file | Git | Use case |
|-------|--------------|-----|----------|
| `user` | `~/.claude/settings.json` | — | Plugin dùng mọi project |
| `project` | `.claude/settings.json` | committed | Plugin chia sẻ với team |
| `local` | `.claude/settings.local.json` | gitignored | Plugin cá nhân cho project |
| `managed` | Admin-controlled | read-only | IT/org-enforced plugins |

---

## Quick Reference

```bash
# Install
claude plugin install <name>@<marketplace>
claude plugin install <name>@<marketplace> --scope project

# List
claude plugin list
claude plugin list --json --available
/plugin

# Enable / Disable
claude plugin enable  <name>@<marketplace>
claude plugin disable <name>@<marketplace>

# Update
claude plugin update <name>@<marketplace>
/reload-plugins

# Remove
claude plugin rm <name>@<marketplace>
claude plugin rm <name>@<marketplace> --prune -y

# Marketplace
claude plugin market add owner/repo
claude plugin market list
claude plugin market remove <name>

# Dev
claude --plugin-dir ./my-plugin    # Load tạm thời
claude plugin validate             # Validate manifest
claude plugin tag --push           # Release
```

---

**Last Updated**: May 8, 2026 | Claude Code v2.1.128+
