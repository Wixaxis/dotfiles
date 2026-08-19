#!/usr/bin/env bash
set -euo pipefail

if ! command -v brew >/dev/null 2>&1; then
  echo "brew is required to check ferdium" >&2
  exit 1
fi

brew list --cask ferdium >/dev/null 2>&1
