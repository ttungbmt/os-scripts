# lib/download.sh — curl wrappers, tarball fetch, checksum verification.

[ -n "${_LIB_DOWNLOAD_LOADED:-}" ] && return 0
_LIB_DOWNLOAD_LOADED=1

# curl wrapper for small/silent fetches (JSON, checksums.txt).
curl_get() {
    curl -fsSL --retry 3 --retry-delay 2 --connect-timeout 10 "$@"
}

# curl wrapper for large downloads — progress bar on a TTY, silent in CI/pipes.
curl_download() {
    local progress="-#"
    [ -t 2 ] || progress="-sS"
    curl -fL ${progress} --retry 3 --retry-delay 2 --connect-timeout 10 "$@"
}

# Download & extract a tarball into a fresh tmp dir. Echoes the tmp path.
# Caller is responsible for cleanup (recommended: trap "rm -rf '${tmp}'" EXIT).
fetch_tarball() {
    local url="$1" tmp
    tmp="$(mktemp -d)"
    log "Downloading ${url}"
    curl_download "${url}" -o "${tmp}/archive.tgz"
    tar -xzf "${tmp}/archive.tgz" -C "${tmp}"
    echo "${tmp}"
}

# Verify SHA256 of an archive against a remote checksums.txt.
# Args: $1 = archive path, $2 = checksums url, $3 = asset filename
# Honors NO_VERIFY env to skip; gracefully skips if tools/file missing.
verify_checksum() {
    local archive="$1" checksums_url="$2" asset="$3" tmp expected actual
    if [ -n "${NO_VERIFY:-}" ]; then
        warn "NO_VERIFY set — skipping checksum verification"
        return 0
    fi
    if ! command -v sha256sum >/dev/null 2>&1; then
        warn "sha256sum not found — skipping checksum verification"
        return 0
    fi
    tmp="$(mktemp)"
    if ! curl_get "${checksums_url}" -o "${tmp}" 2>/dev/null; then
        warn "checksums file not available — skipping verification"
        rm -f "${tmp}"; return 0
    fi
    expected="$(awk -v a="${asset}" '$2==a || $2=="*"a {print $1; exit}' "${tmp}")"
    rm -f "${tmp}"
    [ -n "${expected}" ] || { warn "checksum for ${asset} not listed — skipping"; return 0; }
    actual="$(sha256sum "${archive}" | awk '{print $1}')"
    [ "${expected}" = "${actual}" ] || die "checksum mismatch: expected ${expected}, got ${actual}"
    ok "Checksum verified (sha256)"
}
