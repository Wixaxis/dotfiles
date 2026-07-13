#!/usr/bin/env bash
set -euo pipefail

PROJECTS_DIR="$HOME/.config/herdr/projects"

ITEMS=()
for f in "$PROJECTS_DIR"/*.sh; do
  [ "$(basename "$f")" = "launcher.sh" ] && continue
  [ -x "$f" ] || continue
  ITEMS+=("$(basename "$f" .sh)")
done

[ ${#ITEMS[@]} -eq 0 ] && { echo "No projects found" >&2; sleep 1; exit 1; }

echo "Projects:"
for i in "${!ITEMS[@]}"; do
  printf "  %d) %s\n" $((i + 1)) "${ITEMS[$i]}"
done
echo
read -r -p "pick a project (1-${#ITEMS[@]}): " CHOICE

if [[ "$CHOICE" =~ ^[0-9]+$ ]] && [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -le "${#ITEMS[@]}" ]; then
  exec bash "$PROJECTS_DIR/${ITEMS[$((CHOICE - 1))]}.sh"
fi
