#!/usr/bin/env bash
# =============================================================================
# kustomize Installer — installs `kustomize` from the official GitHub release
#
# USAGE:
#   ./install-kustomize.sh                    # auto-resolve latest (fresh install)
#   ./install-kustomize.sh 5.4.3              # pin version (positional)
#   VERSION=5.4.3 ./install-kustomize.sh      # pin version (env)
#   ./install-kustomize.sh --upgrade          # allow replacing an older version
#   ./install-kustomize.sh --downgrade 5.0.0  # allow replacing with an older version
#   ./install-kustomize.sh --force            # bypass all version checks
#   ./install-kustomize.sh --dry-run          # print plan only
#   ./install-kustomize.sh --help
#
# VARIABLES (override via env):
#   VERSION    : release version, no leading "v" (default: latest)
#   PREFIX     : install prefix (default: /usr/local/bin)
#   BIN_NAME   : binary name (default: kustomize)
#   URL        : full download URL override
#   USE_PROXY  : if set, prepend gh-proxy.com to URLs
#   GH_TOKEN   : GitHub token for higher API rate limit (latest-resolve)
#   UPGRADE / DOWNGRADE / FORCE / DRY_RUN / NO_VERIFY : see SAFETY below
#
# SAFETY:
#   With kustomize already installed, the script REFUSES to replace it unless
#   --upgrade / --downgrade / --force is passed.
# =============================================================================

set -Eeuo pipefail

_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/_lib.sh
source "${_SCRIPT_DIR}/lib/_lib.sh"

main() {
    # Parse flags.
    local positional=""
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)   print_help_from "$0" ;;
            --upgrade)   UPGRADE=1 ;;
            --downgrade) DOWNGRADE=1 ;;
            --force)     FORCE=1 ;;
            --dry-run)   DRY_RUN=1 ;;
            --) shift; positional="${1:-}"; break ;;
            -*) die "Unknown flag: $1 (use --help)" ;;
            *)  positional="$1" ;;
        esac
        shift || true
    done

    local version="${VERSION:-${positional:-}}"
    local prefix="${PREFIX:-/usr/local/bin}"
    local bin_name="${BIN_NAME:-kustomize}"
    local repo="kubernetes-sigs/kustomize"
    local tag_prefix="kustomize/v"

    # kustomize asset uses lowercase OS, amd64-style arch.
    local os arch
    os="$(detect_os lower)"
    arch="$(detect_arch amd64)"

    if [ -z "${version}" ]; then
        log "Resolving latest ${bin_name} version..."
        version="$(resolve_latest_tag_with_prefix "${repo}" "${tag_prefix}")"
    fi
    log "Target: ${bin_name} v${version} (${os}/${arch}) → ${prefix}/${bin_name}"

    # Version gate.
    local current path action
    current="$(extract_semver "$(installed_version "${bin_name}")")"
    path="$(command -v "${bin_name}" 2>/dev/null || echo "${prefix}/${bin_name}")"
    action="$(version_gate "${bin_name}" "${current}" "${version}" "${path}")"
    [ "${action}" = "skip" ] && return 0

    # Build URLs. Asset: kustomize_v<ver>_<os>_<arch>.tar.gz
    local asset url checksums_url release_base
    asset="${bin_name}_v${version}_${os}_${arch}.tar.gz"
    release_base="https://github.com/${repo}/releases/download/${tag_prefix}${version}"
    url="${URL:-${release_base}/${asset}}"
    checksums_url="${release_base}/checksums.txt"
    url="$(maybe_proxy "${url}")"
    checksums_url="$(maybe_proxy "${checksums_url}")"

    if [ -n "${DRY_RUN:-}" ]; then
        log "DRY_RUN — would download:"
        log "  asset:     ${asset}"
        log "  url:       ${url}"
        log "  checksums: ${checksums_url}"
        log "  install:   ${prefix}/${bin_name}"
        return 0
    fi

    local tmp bin_path
    tmp="$(fetch_tarball "${url}")"
    # shellcheck disable=SC2064
    trap "rm -rf '${tmp}'" EXIT INT TERM

    verify_checksum "${tmp}/archive.tgz" "${checksums_url}" "${asset}"

    bin_path="$(locate_binary "${tmp}" "${bin_name}")"
    install_binary "${bin_path}" "${prefix}" "${bin_name}"

    local installed
    installed="$(installed_version "${prefix}/${bin_name}")"
    [ -n "${installed}" ] && log "Version: ${installed}"
}

if [ "${BASH_SOURCE[0]:-$0}" = "$0" ]; then
    main "$@"
fi
