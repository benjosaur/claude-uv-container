# claude-uv-container

A Docker container for running [Claude Code](https://claude.ai) with [uv](https://docs.astral.sh/uv/) in a sandboxed environment — no Node.js required.

## What's included

- **Claude Code** — installed via native installer
- **uv** — fast Python package/project manager
- **zsh** with Powerlevel10k, git, and fzf plugins
- **git-delta** — better git diffs
- **Optional network firewall** — locks outbound traffic to only Anthropic API and PyPI

## Prerequisites

- Docker Desktop (Apple Silicon / ARM64 supported)
- Claude Code logged in on your host machine (`~/.claude` must exist with a valid session)

## Quick start

```bash
docker compose up -d --build
docker compose exec claude-uv-container zsh
```

Once inside the container, run `claude` to start Claude Code. Your host's OAuth session is bind-mounted in, so no login is required.

## Network firewall (optional)

To restrict the container's network access to only essential domains (Anthropic API, PyPI, statsig):

```bash
sudo /usr/local/bin/init-firewall.sh
```

This requires the `NET_ADMIN` and `NET_RAW` capabilities, which are already granted in the compose file.

### Allowed domains

- `api.anthropic.com`
- `sentry.io`
- `statsig.anthropic.com` / `statsig.com`
- `pypi.org` / `files.pythonhosted.org`

All other outbound traffic is blocked.

## Volumes

| Volume | Purpose |
|---|---|
| `.:/workspace` | Your project directory mounted into the container |
| `~/.claude:/home/claude/.claude` | Bind-mount of host Claude config (OAuth session, settings) |
| `claude-code-bashhistory:/commandhistory` | Persistent shell history across rebuilds |

## Configuration

Build args can be customized in `docker-compose.yml`:

| Arg | Default | Description |
|---|---|---|
| `TZ` | `America/Los_Angeles` | Container timezone |
| `GIT_DELTA_VERSION` | `0.18.2` | git-delta release version |
| `ZSH_IN_DOCKER_VERSION` | `1.2.0` | zsh-in-docker release version |
