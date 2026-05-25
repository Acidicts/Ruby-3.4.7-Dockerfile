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
    ca-certificates \
    curl \
    git \
    openssh-client \
    less \
    iproute2 \
    procps \
    gnupg2 \
    build-essential \
    autoconf \
    bison \
    gawk \
    libssl-dev \
    libreadline-dev \
    libyaml-dev \
    libgdbm-dev \
    libncurses5-dev \
    libffi-dev \
    libgmp-dev \
    libdb-dev \
    libsqlite3-dev \
    liblzma-dev \
    libxml2-dev \
    libxslt1-dev \
    libcurl4-openssl-dev \
    libtool \
    pkg-config \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Clean up/remove any broken or inherited Yarn apt sources if they exist
RUN rm -f /etc/apt/sources.list.d/yarn.list \
          /usr/share/keyrings/yarnkey.gpg \
          /etc/apt/sources.list.d/yarn.list.bak

# Install RVM (Ruby Version Manager) for easy switching between Ruby versions.
# This is a multi-user install under /usr/local/rvm.
ENV RVM_PATH=/usr/local/rvm \
    RVM_HOME=/usr/local/rvm \
    PATH=/usr/local/rvm/bin:$PATH \
    rvm_silence_path_mismatch_check_flag=1

ARG RVM_VERSION=1.29.12

RUN bash -lc 'set -euxo pipefail; \
    getent group rvm >/dev/null || groupadd -r rvm; \
    export GNUPGHOME="$(mktemp -d)"; \
    curl -fsSL https://rvm.io/mpapis.asc | gpg --batch --import; \
    curl -fsSL https://rvm.io/pkuczynski.asc | gpg --batch --import; \
    curl -fsSL -o /tmp/rvm.tar.gz "https://github.com/rvm/rvm/archive/refs/tags/${RVM_VERSION}.tar.gz"; \
    tar -xzf /tmp/rvm.tar.gz -C /tmp; \
    cd /tmp/rvm-${RVM_VERSION}; \
    ./install --path "$RVM_PATH"; \
    rm -rf "$GNUPGHOME" /tmp/rvm.tar.gz /tmp/rvm-${RVM_VERSION}; \
    usermod -aG rvm "$USERNAME"; \
    printf "%s" $'"'"'if [ "${GEM_HOME:-}" = "/usr/local/bundle" ]; then\n  case ":${PATH:-}:" in\n    *:/usr/local/bundle/bin:*) ;;\n    *) export PATH="${PATH:+$PATH:}/usr/local/bundle/bin" ;;\n  esac\nfi\n'"'"' > /etc/profile.d/zz-ruby-bundle-path.sh; \
    printf "%s" $'\nif [[ -s "/etc/profile.d/rvm.sh" ]]; then\n  source "/etc/profile.d/rvm.sh"\nfi\n\nif [[ -s "/etc/profile.d/zz-ruby-bundle-path.sh" ]]; then\n  source "/etc/profile.d/zz-ruby-bundle-path.sh"\nfi\n' >> /etc/bash.bashrc

RUN bash -lc "rvm --version"

# Pre-install Rails and Bundler without extra documentation bloat
RUN gem install rails bundler --no-document

# Verify everything is on the PATH and installed correctly
RUN rails --version && ruby --version && bundler --version

# Set the default container user to the non-root vscode user
USER vscode
