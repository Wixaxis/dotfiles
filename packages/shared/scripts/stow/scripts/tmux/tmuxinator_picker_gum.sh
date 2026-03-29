#!/bin/bash
set -euo pipefail

projects() {
  for f in ~/.config/tmuxinator/*.yml; do
    [[ -f "$f" ]] && basename "$f" .yml
  done | sort
}

active() {
  tmux list-sessions -F '#{session_name}' 2>/dev/null
}

format() {
  local active_sessions
  active_sessions=$(active)
  while IFS= read -r p; do
    echo "$active_sessions" | grep -qFx "$p" && echo "* $p" || echo "  $p"
  done
}

selected=$(projects | format | gum filter --header "Select tmuxinator project:" --placeholder "Search...")
[[ -z "$selected" ]] && exit 1

project=$(echo "$selected" | sed 's/^[* ]*//')
active | grep -qFx "$project" && tmux switch-client -t "$project" || tmuxinator start "$project"
