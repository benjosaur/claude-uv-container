# CLAUDE.md

## Project overview

Sandboxed Docker container for running Claude Code with uv. All container config lives in `docker/`. Git worktrees are created in `worktrees/` (gitignored).

## Workflow

### 1. Start the container

```bash
docker compose -f docker/docker-compose.yml up -d --build
```

### 2. Run Claude Code in iTerm

```bash
docker exec -it claude-uv-container claude
```

This opens an interactive Claude Code session inside the container, visible in your current iTerm pane.

### 3. Spawn more Claude instances in new iTerm splits

```bash
source spawn.sh
spawn feature/my-thing -p "implement the login flow"
```

Each spawn:

1. Creates a git worktree at `worktrees/<name>/` with a new branch
2. Opens a new iTerm split pane
3. Runs `docker exec` into the **same running container**, starting another claude instance pointed at the worktree

You can spawn as many as you want — they all share the single container (and its firewall, auth session, etc).

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
- `spawn.sh` — host-side iTerm worktree spawner (not part of Docker build)
- `worktrees/` — git worktrees created by spawn (gitignored)
