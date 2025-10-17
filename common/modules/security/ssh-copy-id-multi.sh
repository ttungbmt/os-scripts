#!/usr/bin/env bash

# === USER CONFIG (edit here) ===
USER_NAME="${USER_NAME:-oracle}"  # allow override via env
KEY_PATH="${KEY_PATH:-$HOME/.ssh/home-tungtt-dev/id_ed25519-home-tungtt-dev}"
# Fallback hosts if none supplied via env/args/file
DEFAULT_HOSTS=(192.168.11.114 192.168.11.115 192.168.11.116)

# === TEMPLATE CONFIG (rarely change) ===
SSH_CONNECT_TIMEOUT="${SSH_CONNECT_TIMEOUT:-7}"
PASSWORD="${PASSWORD:-oracle}"  # default; override with env if needed

# --- Inputs ---
# Accept hosts from (priority):
# 1) CLI args: ./ssh-distribute-key.sh 10.0.0.1 10.0.0.2 ...
# 2) HOSTS env: "10.0.0.1,10.0.0.2" or "10.0.0.1 10.0.0.2"
# 3) HOSTS_FILE env: path to file (one host per line, supports comments/#)
# 4) DEFAULT_HOSTS fallback
parse_hosts() {
  local -a arr=()
  if [ "$#" -gt 0 ]; then
    arr=("$@")
  elif [ -n "${HOSTS:-}" ]; then
    read -r -a arr <<<"$(echo "$HOSTS" | tr ',' ' ')"
  elif [ -n "${HOSTS_FILE:-}" ]; then
    mapfile -t arr < <(grep -vE '^\s*#|^\s*$' "$HOSTS_FILE")
  else
    arr=("${DEFAULT_HOSTS[@]}")
  fi
  echo "${arr[@]}"
}

main() {
  # Ensure public key exists
  [ -f "${KEY_PATH}.pub" ] || { echo "Public key not found: ${KEY_PATH}.pub"; exit 1; }

  # Resolve hosts
  read -r -a HOSTS_ARR <<<"$(parse_hosts "$@")"
  [ "${#HOSTS_ARR[@]}" -gt 0 ] || { echo "No hosts provided."; exit 1; }

  # Non-interactive SSH options
  SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=${SSH_CONNECT_TIMEOUT} \
            -o PreferredAuthentications=password -o PubkeyAuthentication=no"

  command -v sshpass >/dev/null || { echo "Install sshpass (e.g., dnf install -y sshpass)"; exit 1; }

  for ip in "${HOSTS_ARR[@]}"; do
    echo ">>> ${USER_NAME}@${ip}"
    if ! sshpass -p "$PASSWORD" ssh-copy-id -i "${KEY_PATH}.pub" $SSH_OPTS "${USER_NAME}@${ip}" >/dev/null 2>&1; then
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
}

main "$@"
