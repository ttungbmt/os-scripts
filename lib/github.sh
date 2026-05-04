# lib/github.sh — GitHub release helpers.
# Depends on: log.sh (die), download.sh (curl_get).

[ -n "${_LIB_GITHUB_LOADED:-}" ] && return 0
_LIB_GITHUB_LOADED=1

# Resolve latest release tag for "owner/repo" without burning GitHub API quota.
# Uses the HTML redirect endpoint with JSON Accept; strips leading "v".
# Use this for single-product repos.
resolve_latest_version() {
    local repo="$1" ver
    ver="$(curl_get -H 'Accept: application/json' \
        "https://github.com/${repo}/releases/latest" \
        | sed -e 's/.*"tag_name":"v\?\([^"]*\)".*/\1/')"
    [ -n "${ver}" ] || die "Failed to resolve latest version for ${repo}"
    echo "${ver}"
}

# Resolve latest tag whose name starts with a given prefix, for monorepos that
# release multiple components (e.g. "kustomize/vX.Y.Z" in kubernetes-sigs/kustomize).
# Args: $1 = repo (owner/name), $2 = tag prefix (e.g. "kustomize/v")
# Returns: version with the prefix stripped (e.g. "5.8.1").
# Note: hits api.github.com (60 req/h unauth). Set GH_TOKEN to lift the limit.
resolve_latest_tag_with_prefix() {
    local repo="$1" prefix="$2" tag ver
    local -a hdr=(-H 'Accept: application/json')
    [ -n "${GH_TOKEN:-}" ] && hdr+=(-H "Authorization: Bearer ${GH_TOKEN}")
    # `|| true` to shield set -o pipefail when grep finds no match.
    tag="$(curl_get "${hdr[@]}" \
        "https://api.github.com/repos/${repo}/releases?per_page=50" \
        | { grep -oE "\"tag_name\":[[:space:]]*\"${prefix}[^\"]+\"" || true; } \
        | head -n1 \
        | sed -E 's/.*"([^"]+)".*/\1/')"
    [ -n "${tag}" ] || die "No release found with prefix '${prefix}' in ${repo}"
    ver="${tag#"${prefix}"}"
    echo "${ver}"
}

# Apply gh-proxy prefix when USE_PROXY is set in env.
maybe_proxy() {
    local url="$1"
    if [ -n "${USE_PROXY:-}" ]; then
        echo "https://gh-proxy.com/${url}"
    else
        echo "${url}"
    fi
}
