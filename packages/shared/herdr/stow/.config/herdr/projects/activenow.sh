#!/usr/bin/env bash
set -euo pipefail

LABEL="activenow"
CWD="$HOME/work/activenow"

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

herdr pane run "${WS}:p1" "nvim"
herdr tab create --label codex
sleep 0.1
herdr pane run "${WS}:p2" "codex"
herdr tab create --label notes
sleep 0.1
herdr pane run "${WS}:p3" "cd ~/Notes && nvim work/dash.md"
herdr tab create --label terminal
sleep 0.1
herdr pane run "${WS}:p4" "fastfetch && exec zsh"

herdr tab create --label runtime
sleep 0.1
herdr pane run "${WS}:p5" "bundle exec rails s"
herdr pane split "${WS}:p5" --direction right
sleep 0.1
herdr pane run "${WS}:p6" "bundle exec sidekiq"
herdr pane split "${WS}:p6" --direction down
sleep 0.1
herdr pane run "${WS}:p7" "bin/dev"
