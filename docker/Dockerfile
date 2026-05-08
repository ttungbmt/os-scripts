FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    tar \
    unzip \
    bash \
    sudo \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user 'ubuntu' (UID 1000) with passwordless sudo – mirrors WSL
RUN groupadd -g 1000 ubuntu \
    && useradd -m -u 1000 -g ubuntu -s /bin/zsh ubuntu \
    && echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ubuntu \
    && chmod 0440 /etc/sudoers.d/ubuntu

WORKDIR /workspace
RUN chown ubuntu:ubuntu /workspace

# Copy gc CLI to support the gc command inside the container
COPY gc /usr/local/bin/gc
RUN chmod +x /usr/local/bin/gc

USER ubuntu

RUN gc install multi git bats
RUN gc install multi gem
RUN gc install multi bashly
RUN gc install multi zsh antidote
RUN gc install multi mise node