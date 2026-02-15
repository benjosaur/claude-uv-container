# claude-uv-container

A Docker container for running [Claude Code](https://claude.ai) with [uv](https://docs.astral.sh/uv/) in a sandboxed environment — no Node.js required.

## What's included

- **Claude Code** — installed via native installer
- **uv** — fast Python package/project manager
- **zsh** with Powerlevel10k, git, and fzf plugins
- **git-delta** — better git diffs
- **Network firewall** — locks outbound traffic to only Anthropic API and PyPI
- **spawn** — script to spin up Claude instances in git worktrees via iTerm splits

## Prerequisites

- Docker Desktop (Apple Silicon / ARM64 supported)
- Claude Code logged in on your host machine (`~/.claude` must exist with a valid session)

## Setup

```bash
git clone https://github.com/youruser/claude-uv-container.git
cd claude-uv-container

# Start the container
docker compose -f docker/docker-compose.yml up -d --build
```

## Working on a project

Clone a repo into `projects/` on your Mac, then run Claude on it inside the container:

```bash
# Clone on host (container firewall blocks github.com)
git clone https://github.com/user/some-repo.git projects/some-repo

# Run Claude on it inside the container
docker exec -it -w /workspace/projects/some-repo claude-uv-container claude
```

The `projects/` directory is bind-mounted into the container at `/workspace/projects/` — same files, no copy needed. Your host's `~/.claude` OAuth session is also mounted in, so no login is required.

## Spawning worktree instances

### In-container (tmux)

Connect to the container with a tmux session, then spawn Claude instances in new panes — no host-side tools needed:

```bash
# Connect (creates session on first run, reattaches after)
docker exec -it claude-uv-container tmux new-session -A -s main

# Spawn a Claude instance in a new tmux pane
spawn feature/my-thing -p "implement the login flow"
```

Each `spawn` creates a git worktree and splits the current tmux pane with Claude running in it.

Detach with `Ctrl-b d` — all sessions keep running. Reconnect anytime with the same `docker exec` command.

<details>
<summary>tmux basics</summary>

| Key | Action |
|---|---|
| `Ctrl-b d` | Detach (sessions persist) |
| `Ctrl-b %` | Manual vertical split |
| `Ctrl-b "` | Manual horizontal split |
| `Ctrl-b o` | Switch pane |
| `Ctrl-b x` | Close pane |

</details>

### Host-side (iTerm)

`spawn.sh` is an alternative for macOS/iTerm users that creates iTerm splits instead of tmux panes:

```bash
source ~/Projects/claude-uv-container/spawn.sh
spawn feature/my-thing -p "implement the login flow"
```

This creates a worktree at `worktrees/my-thing/`, opens an iTerm split, and runs `claude` inside the container pointed at that worktree. The container must already be running.

## Project structure

```
claude-uv-container/
├── docker/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── init-firewall.sh
│   └── spawn-tmux.sh
├── projects/               # clone repos here (gitignored)
├── worktrees/              # git worktrees (gitignored)
├── spawn.sh
├── README.md
└── .gitignore
```

## Network firewall

The firewall initializes automatically on container start. It restricts outbound traffic to:

- `api.anthropic.com`
- `platform.claude.ai` / `claude.ai` (OAuth)
- `sentry.io`
- `statsig.anthropic.com` / `statsig.com`
- `pypi.org` / `files.pythonhosted.org`

All other outbound traffic is blocked.

## Volumes

| Volume | Purpose |
|---|---|
| `..:/workspace` | Repo root mounted into the container |
| `~/.claude:/home/claude/.claude` | Bind-mount of host Claude config (OAuth session, settings) |
| `claude-code-bashhistory:/commandhistory` | Persistent shell history across rebuilds |

## Configuration

Build args can be customized in `docker/docker-compose.yml`:

| Arg | Default | Description |
|---|---|---|
| `TZ` | `America/Los_Angeles` | Container timezone |
| `GIT_DELTA_VERSION` | `0.18.2` | git-delta release version |
| `ZSH_IN_DOCKER_VERSION` | `1.2.0` | zsh-in-docker release version |
