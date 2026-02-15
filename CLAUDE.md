# CLAUDE.md

## Project overview

Sandboxed Docker container for running Claude Code with uv. All container config lives in `docker/`. Git worktrees are created in `worktrees/` (gitignored).

## Workflow

### 1. Start the container

```bash
docker compose -f docker/docker-compose.yml up -d --build
```

### 2. Connect with tmux

```bash
docker exec -it claude-uv-container tmux new-session -A -s main
```

This creates (or reattaches to) a tmux session inside the container. From here you can run `claude` or use `spawn` to create parallel instances.

### 3. Spawn more Claude instances

Inside the tmux session:

```bash
spawn feature/my-thing -p "implement the login flow"
```

Each spawn:

1. Creates a git worktree at `worktrees/<name>/` with a new branch
2. Splits the current tmux pane
3. Runs `claude` in the new pane pointed at the worktree

Detach with `Ctrl-b d` — all sessions keep running. Reconnect with the same `docker exec` command.

Alternatively, use `spawn.sh` from the host for iTerm splits (see below).

### 4. Stop

```bash
docker compose -f docker/docker-compose.yml down
```

## spawn.sh

**Host-side only** — runs on macOS using osascript to control iTerm. Do not move into `docker/`.

- Must be `source`d, not executed (`source spawn.sh`, not `./spawn.sh`)
- Container must already be running
- Run from the repo root

## File layout

- `docker/Dockerfile` — container image definition
- `docker/docker-compose.yml` — compose config (build context is repo root `..`)
- `docker/init-firewall.sh` — network firewall, runs automatically on container start
- `docker/spawn-tmux.sh` — in-container tmux spawn function (copied into image)
- `spawn.sh` — host-side iTerm worktree spawner (not part of Docker build)
- `worktrees/` — git worktrees created by spawn (gitignored)
