#!/usr/bin/env bash
# === Naming rule ===
# name: <source(org/project)>-<team>-<env>-<role/svc>

# === USER CONFIG (edit here) ===
USER_NAME="oracle"
SOURCE="local"
TEAM="tungtt"
ENV="dev"
HOSTS=(
  192.168.11.10
  192.168.11.101
  192.168.11.102
  192.168.11.111
  192.168.11.112
  192.168.11.113
  192.168.11.121
  192.168.11.122
  192.168.11.123
  192.168.11.131
  192.168.11.132
  192.168.11.133
  192.168.11.141
)

# === TEMPLATE CONFIG (rarely change) ===
NAME="${SOURCE}-${TEAM}-${ENV}"
KEY_PATH="${KEY_PATH:-$HOME/.ssh/${NAME}/id_ed25519-${NAME}}"
COMMENT="${COMMENT:-${USER_NAME}@${NAME}}"
KEY_ALGO="${KEY_ALGO:-ed25519}"
KDF_ROUNDS="${KDF_ROUNDS:-100}"
SSH_CONNECT_TIMEOUT="${SSH_CONNECT_TIMEOUT:-7}"
SSHSCAN_TIMEOUT="${SSHSCAN_TIMEOUT:-5}"

# === Ensure key exists ===
if [ ! -f "$KEY_PATH" ]; then
  mkdir -p "$(dirname "$KEY_PATH")"
  ssh-keygen -t "$KEY_ALGO" -a "$KDF_ROUNDS" -C "$COMMENT" -f "$KEY_PATH"
fi

# === Preload host keys ===
mkdir -p "$HOME/.ssh"; chmod 700 "$HOME/.ssh"
tmp_known="$HOME/.ssh/known_hosts.tmp"
: > "$tmp_known"
for ip in "${HOSTS[@]}"; do
  ssh-keyscan -T "$SSHSCAN_TIMEOUT" -H "$ip" >> "$tmp_known" 2>/dev/null || true
done
touch "$HOME/.ssh/known_hosts"
cat "$tmp_known" "$HOME/.ssh/known_hosts" 2>/dev/null | sort -u > "$HOME/.ssh/known_hosts.new"
mv "$HOME/.ssh/known_hosts.new" "$HOME/.ssh/known_hosts"
chmod 644 "$HOME/.ssh/known_hosts"; rm -f "$tmp_known"

# === Copy public key ===
for ip in "${HOSTS[@]}"; do
  echo ">>> ${USER_NAME}@${ip}"
  ssh-copy-id -i "${KEY_PATH}.pub" -o ConnectTimeout="$SSH_CONNECT_TIMEOUT" "${USER_NAME}@${ip}" || {
    echo "!!! Failed: ${ip}" >&2
  }
done

# === Optional ===
# eval "$(ssh-agent -s)"; ssh-add "$KEY_PATH"
# chmod 700 ~/.ssh; chmod 600 "$KEY_PATH"; chmod 644 "${KEY_PATH}.pub"