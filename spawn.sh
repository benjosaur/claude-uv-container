spawn() {
  local PROMPT=""
  local ARG=""

  # --- Parse flags ---
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

  BRANCH="$ARG"
  FOLDER="${ARG##*/}"
  WORKTREE_DIR="worktrees/$FOLDER"
  CONTAINER_DIR="/workspace/worktrees/$FOLDER"

  # --- Create worktree inside the repo ---
  mkdir -p worktrees
  git worktree add -b "$BRANCH" "$WORKTREE_DIR" || return 1

  # --- Smart iTerm split ---
  osascript <<EOF
tell application "iTerm"
  tell current window
    tell current session
      set paneWidth to columns
      set paneHeight to rows

      if paneWidth > paneHeight then
        set newSession to (split horizontally with default profile)
      else
        set newSession to (split vertically with default profile)
      end if

      tell newSession
        write text "docker exec -it -w $CONTAINER_DIR claude-uv-container claude -p \"$PROMPT\""
      end tell
    end tell
  end tell
end tell
EOF
}
