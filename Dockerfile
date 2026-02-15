FROM ubuntu:24.04

ARG TZ
ENV TZ="$TZ"
ARG CLAUDE_CODE_VERSION=latest

# Install basic development tools and iptables/ipset
RUN apt-get update && apt-get install -y --no-install-recommends \
  less \
  git \
  procps \
  sudo \
  fzf \
  zsh \
  man-db \
  unzip \
  gnupg2 \
  iptables \
  ipset \
  iproute2 \
  dnsutils \
  jq \
  nano \
  vim \
  curl \
  wget \
  ca-certificates \
  python3 \
  python3-venv \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create non-root user (replacing the node user from the node image)
ARG USERNAME=claude
RUN groupadd -r $USERNAME && useradd -r -g $USERNAME -m -s /bin/zsh $USERNAME

# Persist bash history
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  && mkdir /commandhistory \
  && touch /commandhistory/.bash_history \
  && chown -R $USERNAME /commandhistory

# Set environment
ENV DEVCONTAINER=true

# Create workspace and config directories
RUN mkdir -p /workspace /home/$USERNAME/.claude && \
  chown -R $USERNAME:$USERNAME /workspace /home/$USERNAME/.claude

WORKDIR /workspace

ARG GIT_DELTA_VERSION=0.18.2
RUN ARCH=$(dpkg --print-architecture) && \
  wget "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  dpkg -i "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  rm "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb"

# Switch to non-root user
USER $USERNAME

# Set shell defaults
ENV SHELL=/bin/zsh
ENV EDITOR=nano
ENV VISUAL=nano

# Install zsh config
ARG ZSH_IN_DOCKER_VERSION=1.2.0
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v${ZSH_IN_DOCKER_VERSION}/zsh-in-docker.sh)" -- \
  -p git \
  -p fzf \
  -a "source /usr/share/doc/fzf/examples/key-bindings.zsh" \
  -a "source /usr/share/doc/fzf/examples/completion.zsh" \
  -a "export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  -x

# Install uv (Python package/project manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/home/${USERNAME}/.local/bin:$PATH"

# Install Claude Code via native installer (no Node.js needed)
RUN curl -fsSL https://claude.ai/install.sh | sh
ENV PATH="/home/${USERNAME}/.claude/bin:$PATH"

# Copy and set up firewall script
COPY init-firewall.sh /usr/local/bin/
USER root
RUN chmod +x /usr/local/bin/init-firewall.sh && \
  echo "$USERNAME ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" > /etc/sudoers.d/$USERNAME-firewall && \
  chmod 0440 /etc/sudoers.d/$USERNAME-firewall
USER $USERNAME