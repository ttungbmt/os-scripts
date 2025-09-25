#!/usr/bin/env bash
# === USER CONFIG (edit here) ===
USER_NAME="oracle"
SOURCE="local"
TEAM="tungtt"
ENV="dev"
PASSPHRASE="${PASSPHRASE:-}"   # để rỗng = không passphrase; hoặc set qua env

# === TEMPLATE CONFIG (rarely change) ===
NAME="${SOURCE}-${TEAM}-${ENV}"
KEY_PATH="${KEY_PATH:-$HOME/.ssh/${NAME}/id_ed25519-${NAME}}"
COMMENT="${COMMENT:-${USER_NAME}@${NAME}}"
KEY_ALGO="${KEY_ALGO:-ed25519}"
KDF_ROUNDS="${KDF_ROUNDS:-100}"

mkdir -p "$(dirname "$KEY_PATH")"
if [ -f "$KEY_PATH" ]; then
  echo "Key exists: $KEY_PATH"
else
  ssh-keygen -t "$KEY_ALGO" -a "$KDF_ROUNDS" -C "$COMMENT" -f "$KEY_PATH" -N "$PASSPHRASE"
  echo "Generated: $KEY_PATH"
fi
