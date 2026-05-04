# lib/install.sh — sudo policy + binary installation.
# Depends on: log.sh.

[ -n "${_LIB_INSTALL_LOADED:-}" ] && return 0
_LIB_INSTALL_LOADED=1

# Echo "" if root, else "sudo".
sudo_cmd() {
    [ "$(id -u)" -eq 0 ] && echo "" || echo sudo
}

# Find a binary inside an extracted dir (top-level or nested up to depth 3).
# Args: $1 = dir, $2 = bin name
locate_binary() {
    local dir="$1" name="$2" path
    if [ -f "${dir}/${name}" ]; then
        echo "${dir}/${name}"; return 0
    fi
    path="$(find "${dir}" -maxdepth 3 -type f -name "${name}" | head -n1 || true)"
    [ -n "${path}" ] || die "Binary '${name}' not found in archive"
    echo "${path}"
}

# Install a binary to PREFIX with mode 0755 (uses sudo if needed). Ensures the
# prefix dir exists.
# Args: $1 = src path, $2 = prefix dir, $3 = bin name
install_binary() {
    local src="$1" prefix="$2" name="$3"
    $(sudo_cmd) install -d "${prefix}"
    $(sudo_cmd) install -m 0755 "${src}" "${prefix}/${name}"
    ok "Installed ${prefix}/${name}"
}
