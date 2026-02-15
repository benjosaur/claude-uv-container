spawn() {
  local PROMPT=""
  local ARG=""

  # --- Parse flags ---
  local OPTIND=1
  while getopts "p:" opt; do
    case $opt in
      p) PROMPT="$OPTARG" ;;
      *) echo "Usage: spawn type/name -p \"prompt\""; return 1 ;;
    esac
  done

  shift $((OPTIND - 1))
  ARG="$1"

  if [ -z "$ARG" ] || [ -z "$PROMPT" ]; then
    echo "Usage: spawn type/name -p \"prompt\""
    return 1
  fi

  # --- Ensure we're inside tmux ---
  if [ -z "$TMUX" ]; then
    echo "Error: spawn requires a tmux session."
    echo "Start one with: tmux new-session -s main"
    return 1
  fi

  BRANCH="$ARG"
  FOLDER="${ARG##*/}"
  WORKTREE_DIR="/workspace/worktrees/$FOLDER"

  # --- Create worktree ---
  mkdir -p /workspace/worktrees
  git -C /workspace worktree add -b "$BRANCH" "$WORKTREE_DIR" || return 1

  # --- Smart tmux split (match iTerm behavior) ---
  PANE_WIDTH=$(tmux display-message -p '#{pane_width}')
  PANE_HEIGHT=$(tmux display-message -p '#{pane_height}')

  if [ "$PANE_WIDTH" -gt "$((PANE_HEIGHT * 3))" ]; then
    SPLIT_FLAG="-h"  # horizontal split (side by side)
  else
    SPLIT_FLAG="-v"  # vertical split (stacked)
  fi

  tmux split-window $SPLIT_FLAG -c "$WORKTREE_DIR" "claude -p \"$PROMPT\""
}
