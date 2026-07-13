#!/usr/bin/env bash
set -euo pipefail

PROJECTS_DIR="$HOME/.config/herdr/projects"

PROJECT=$(for f in "$PROJECTS_DIR"/*.sh; do
  [ "$(basename "$f")" = "launcher.sh" ] && continue
  [ -x "$f" ] || continue
  basename "$f" .sh
done | sort | fzf --prompt="project> " --height=10 --layout=reverse --no-preview)

[ -z "$PROJECT" ] && exit 0

exec bash "$PROJECTS_DIR/$PROJECT.sh"
