#!/usr/bin/env bash
set -euo pipefail
fixtures_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

mkdir -p "$work/fake-tool-1.0.0/bin"
cat > "$work/fake-tool-1.0.0/bin/fake-tool" <<'EOF'
#!/bin/sh
echo "fake v1.0.0"
EOF
chmod +x "$work/fake-tool-1.0.0/bin/fake-tool"
echo "fake tool" > "$work/fake-tool-1.0.0/README.md"

tar -czf "$fixtures_dir/fake-tool.tar.gz" -C "$work" fake-tool-1.0.0
