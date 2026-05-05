FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    tar \
    unzip \
    git \
    bash \
    zsh \
    python3-pip \
    ruby-full \
    && rm -rf /var/lib/apt/lists/*

# Node.js 20 LTS (for claude via npm)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Bats for running unit tests inside container
RUN npm install -g bats

WORKDIR /workspace
