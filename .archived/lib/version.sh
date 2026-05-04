# lib/version.sh — installed version probing + semver compare.

[ -n "${_LIB_VERSION_LOADED:-}" ] && return 0
_LIB_VERSION_LOADED=1

# Echo the raw version string of an installed binary, or empty if not present.
# Tries `--version` then `version`. Caller is responsible for parsing.
installed_version() {
    local bin="$1"
    command -v "${bin}" >/dev/null 2>&1 || { echo ""; return; }
    "${bin}" --version 2>/dev/null || "${bin}" version 2>/dev/null || true
}

# Extract the first semver-looking token (X.Y.Z, optional -suffix) from text.
# Trailing `|| true` shields against `set -o pipefail` when grep finds no match.
extract_semver() {
    echo "$1" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9.+-]+)?' | head -n1 || true
}

# Compare two semver strings using `sort -V`. Echoes "eq" | "lt" | "gt" (a vs b).
semver_compare() {
    local a="$1" b="$2" first
    [ "${a}" = "${b}" ] && { echo eq; return; }
    first="$(printf '%s\n%s\n' "${a}" "${b}" | sort -V | head -n1)"
    [ "${first}" = "${a}" ] && echo lt || echo gt
}

# Enforce upgrade/downgrade gating.
# Args: $1 = bin name (for messages), $2 = current version, $3 = target version, $4 = path
# Reads env: FORCE, UPGRADE, DOWNGRADE.
# Returns: 0 = proceed (or skip if equal — caller must check echo "skip"),
#          exits 2 = refused.
# Echoes one of: "skip" | "install" | "upgrade" | "downgrade"
version_gate() {
    local name="$1" current="$2" target="$3" path="$4"

    # Fresh install: nothing to compare.
    if [ -z "${current}" ]; then
        echo install; return 0
    fi

    # FORCE bypass.
    if [ -n "${FORCE:-}" ]; then
        echo install; return 0
    fi

    local cmp; cmp="$(semver_compare "${current}" "${target}")"
    case "${cmp}" in
        eq)
            ok "${name} v${target} already installed at ${path} — skipping"
            log "Set FORCE=1 to reinstall the same version"
            echo skip; return 0
            ;;
        lt)
            if [ -z "${UPGRADE:-}" ]; then
                err "Refusing to upgrade ${name}: ${current} → ${target} (at ${path})"
                err "Pass --upgrade or set UPGRADE=1 to proceed (or FORCE=1 to bypass)"
                exit 2
            fi
            log "Upgrading ${name}: ${current} → ${target}"
            echo upgrade; return 0
            ;;
        gt)
            if [ -z "${DOWNGRADE:-}" ]; then
                err "Refusing to downgrade ${name}: ${current} → ${target} (at ${path})"
                err "Pass --downgrade or set DOWNGRADE=1 to proceed (or FORCE=1 to bypass)"
                exit 2
            fi
            warn "Downgrading ${name}: ${current} → ${target}"
            echo downgrade; return 0
            ;;
    esac
}
