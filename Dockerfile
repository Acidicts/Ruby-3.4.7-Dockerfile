# Start directly from the official Ruby 3.4.7 Debian-based image
FROM ruby:3.4.7-bookworm

# Configure environment variables for a non-interactive, UTF-8 environment
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

# Replicate the default 'vscode' non-root user that Microsoft devcontainers expect
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # Add sudo support for the non-root user
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(ALL\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Install standard development utilities included in Microsoft Devcontainers
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    openssh-client \
    less \
    iproute2 \
    procps \
    gnupg2 \
    build-essential \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Clean up/remove any broken or inherited Yarn apt sources if they exist
RUN rm -f /etc/apt/sources.list.d/yarn.list \
          /usr/share/keyrings/yarnkey.gpg \
          /etc/apt/sources.list.d/yarn.list.bak

# Pre-install Rails and Bundler without extra documentation bloat
RUN gem install rails bundler --no-document

# Verify everything is on the PATH and installed correctly
RUN rails --version && ruby --version && bundler --version

# Set the default container user to the non-root vscode user
USER vscode
