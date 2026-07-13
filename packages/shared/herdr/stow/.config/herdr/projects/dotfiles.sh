#!/usr/bin/env bash
set -euo pipefail

LABEL="dotfiles"
CWD="$HOME/dotfiles"

EXISTING=$(herdr workspace list | python3 -c "
import sys, json
for w in json.load(sys.stdin).get('result', {}).get('workspaces', []):
    if w.get('label') == '$LABEL':
        print(w['workspace_id'])
        break
" 2>/dev/null)

if [ -n "$EXISTING" ]; then
  herdr workspace focus "$EXISTING"
  exit 0
fi

herdr workspace create --cwd "$CWD" --label "$LABEL" --focus
sleep 0.3

WS=$(herdr workspace list | python3 -c "
import sys, json
for w in json.load(sys.stdin).get('result', {}).get('workspaces', []):
    if w.get('label') == '$LABEL':
        print(w['workspace_id'])
        break
")

[ -z "$WS" ] && { echo "ERROR: failed to create workspace $LABEL" >&2; exit 1; }

herdr pane run "${WS}:p1" "opencode -c"
herdr tab create --label shell
sleep 0.1
herdr pane run "${WS}:p2" "zsh"
herdr tab create --label lazygit
sleep 0.1
herdr pane run "${WS}:p3" "lazygit"
herdr tab create --label editor
sleep 0.1
herdr pane run "${WS}:p4" "nvim"
