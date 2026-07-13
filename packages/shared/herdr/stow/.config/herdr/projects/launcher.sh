#!/usr/bin/env bash
set -euo pipefail

PROJECTS_DIR="$HOME/.config/herdr/projects"

PROJECT=$(for f in "$PROJECTS_DIR"/*.sh; do
  [ -x "$f" ] || continue
  basename "$f" .sh
done | sort | gum filter --placeholder "pick a project…" --prompt="▶ " 2>/dev/null)

[ -z "$PROJECT" ] && exit 0

exec bash "$PROJECTS_DIR/$PROJECT.sh"
