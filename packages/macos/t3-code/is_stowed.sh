#!/usr/bin/env bash
set -euo pipefail

if ! command -v brew >/dev/null 2>&1; then
  echo "brew is required to check t3-code" >&2
  exit 1
fi

brew list --cask t3-code >/dev/null 2>&1
