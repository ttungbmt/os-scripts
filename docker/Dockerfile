# ── Stage 1: system ──────────────────────────────────────────────────────────
# Stable layer: apt packages, SSH config, ubuntu user.
# Rebuilt only when system-level dependencies change.
FROM ubuntu:22.04 AS system
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    tar \
    unzip \
    bash \
    sudo \
    python3-pip \
    openssh-client \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd \
    && sed -i \
        -e 's/^#\?PermitRootLogin.*/PermitRootLogin no/' \
        -e 's/^#\?AllowAgentForwarding.*/AllowAgentForwarding yes/' \
        -e 's/^#\?AllowTcpForwarding.*/AllowTcpForwarding yes/' \
        /etc/ssh/sshd_config \
    && ssh-keygen -A

RUN groupadd -g 1000 ubuntu \
    && useradd -m -u 1000 -g ubuntu -s /bin/zsh ubuntu \
    && echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ubuntu \
    && chmod 0440 /etc/sudoers.d/ubuntu

# ── Stage 2: tools ───────────────────────────────────────────────────────────
# Heavy layer: installs all DevOps tools via gc.
# Each RUN is a separate cache layer — reorder to put frequently-changed tools last.
FROM system AS tools

WORKDIR /home/ubuntu/workspace
RUN chown ubuntu:ubuntu /home/ubuntu/workspace

COPY gc /usr/local/bin/gc
RUN chmod +x /usr/local/bin/gc

USER ubuntu

# Rarely changes
RUN gc install multi git bats rsync

# Runtime manager (pin version separately for cache isolation)
RUN gc install multi mise

# Language runtimes via mise
RUN gc install python --version 3.11 && \
    gc install multi node bun

# Ruby + Bashly (dev tooling)
RUN gc install multi gem bashly

# Shell environment tools
RUN gc install multi starship zsh antidote direnv zoxide bat eza fzf fd ripgrep thefuck mcfly

# Frequently updated — keep last for best cache hit rate
RUN gc install claude

# Bootstrap zsh plugins
RUN zsh -c 'gc setup antidote && source ~/.zshrc && antidote update'

# ── Stage 3: runtime ─────────────────────────────────────────────────────────
# Final image: clean system + tool artifacts copied from tools stage.
# Does not carry build-time temp files or intermediate apt caches.
FROM system AS runtime

WORKDIR /home/ubuntu/workspace
RUN chown ubuntu:ubuntu /home/ubuntu/workspace

COPY --from=tools /usr/local/bin/  /usr/local/bin/
COPY --from=tools /usr/local/share/ /usr/local/share/
COPY --from=tools --chown=ubuntu:ubuntu /home/ubuntu/ /home/ubuntu/

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
