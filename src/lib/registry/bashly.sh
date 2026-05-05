bashly_fetch_local_version() {
  local target="$1"
  "$target" --version 2>/dev/null
}

bashly_fetch_remote_version() {
  curl -s "https://rubygems.org/api/v1/versions/bashly/latest.json" | grep -o '"version":"[^"]*"' | cut -d'"' -f4
}
