#!/usr/bin/env bash
set -e -o pipefail

# === USER CONFIG (edit here) ===
KEY_PATH="${KEY_PATH:-$HOME/.ssh/local-tungtt-dev/id_ed25519-local-tungtt-dev}"
HOSTS=(
  192.168.11.101
  192.168.11.102
)
# Default password (override with: PASSWORD='...' bash ssh-distribute-key.sh)
PASSWORD="${PASSWORD:-oracle}"

# === TEMPLATE CONFIG (rarely change) ===
SSH_CONNECT_TIMEOUT="${SSH_CONNECT_TIMEOUT:-7}"

# Ensure public key exists
[ -f "${KEY_PATH}.pub" ] || { echo "Public key not found: ${KEY_PATH}.pub"; exit 1; }

# Non-interactive SSH options (skip first-time fingerprint & use password)
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=${SSH_CONNECT_TIMEOUT} \
          -o PreferredAuthentications=password -o PubkeyAuthentication=no"

# Make sure sshpass is available
command -v sshpass >/dev/null || { echo "Install sshpass (e.g., dnf install -y sshpass)"; exit 1; }

# Push public key to each host using PASSWORD variable (no prompts)
for ip in "${HOSTS[@]}"; do
  echo ">>> ${USER_NAME}@${ip}"
  if ! sshpass -p "$PASSWORD" ssh-copy-id -i "${KEY_PATH}.pub" $SSH_OPTS "${USER_NAME}@${ip}" >/dev/null 2>&1; then
    # Fallback if ssh-copy-id is unavailable on remote
    PUB=$(cat "${KEY_PATH}.pub")
    sshpass -p "$PASSWORD" ssh $SSH_OPTS "${USER_NAME}@${ip}" \
      "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo '$PUB' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys" \
      >/dev/null
  fi
done

echo "Done."

# Optional: enable agent and set key permissions
# eval "$(ssh-agent -s)"; ssh-add "$KEY_PATH"
# chmod 700 ~/.ssh; chmod 600 "$KEY_PATH"; chmod 644 "${KEY_PATH}.pub"