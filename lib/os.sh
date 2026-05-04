# lib/os.sh — OS / architecture detection in the naming style required by
# upstream release assets (different projects pick different conventions).

[ -n "${_LIB_OS_LOADED:-}" ] && return 0
_LIB_OS_LOADED=1

# Detect OS.
# Args: $1 = style ("title"=Linux/Darwin, "lower"=linux/darwin)
detect_os() {
    local style="${1:-title}"
    local raw
    raw="$(uname -s)"
    case "${raw}" in
        Linux|Darwin) ;;
        *) die "Unsupported OS: ${raw}" ;;
    esac
    case "${style}" in
        title) echo "${raw}" ;;
        lower) echo "${raw}" | tr '[:upper:]' '[:lower:]' ;;
        *) die "Unknown OS style: ${style}" ;;
    esac
}

# Detect ARCH.
# Args: $1 = style ("x86_64"|"amd64")
# Always normalizes aarch64 → arm64.
detect_arch() {
    local style="${1:-x86_64}"
    local raw
    raw="$(uname -m)"
    case "${raw}" in
        x86_64|amd64)   [ "${style}" = "amd64" ] && echo "amd64" || echo "x86_64" ;;
        arm64|aarch64)  echo "arm64" ;;
        *) die "Unsupported architecture: ${raw}" ;;
    esac
}
