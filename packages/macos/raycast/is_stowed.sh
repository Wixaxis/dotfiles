#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
PACKAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RAYCAST_APP="/Applications/Raycast Beta.app"
EXPECTED_BUNDLE_ID="com.raycast-x.macos"

if [[ ! -d "$RAYCAST_APP" ]]; then
  echo "Raycast v2 beta is not installed at $RAYCAST_APP" >&2
  exit 1
fi

actual_bundle_id="$(defaults read "$RAYCAST_APP/Contents/Info" CFBundleIdentifier 2>/dev/null || true)"
if [[ "$actual_bundle_id" != "$EXPECTED_BUNDLE_ID" ]]; then
  echo "Unexpected Raycast v2 beta bundle identifier: $actual_bundle_id" >&2
  exit 1
fi

exec "$ROOT/scripts/package-run.sh" "$PACKAGE_DIR" --generic-check
