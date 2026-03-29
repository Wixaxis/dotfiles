#!/bin/bash
# Device-specific Hyprland config overrides
# Sets defaults first, then applies device-specific settings

set -euo pipefail

HOSTNAME=$(uname -n)

# Delay to ensure config is fully loaded before applying overrides
sleep 0.3

# ──────────────────────────────────────────────────────────────
#  Default Settings (applied to all devices)
# ──────────────────────────────────────────────────────────────

# Default input sensitivity
hyprctl keyword input:sensitivity -0.6

# Default hyrscrolling column width (49%)
hyprctl keyword plugin:hyprscrolling:column_width 0.49


# ──────────────────────────────────────────────────────────────
#  Device-Specific Overrides
# ──────────────────────────────────────────────────────────────

case "$HOSTNAME" in
    wixaxis-minibook)
        # Faster cursor speed for minibook
        hyprctl keyword input:sensitivity 0.0
        # Wider windows for minibook (90% width)
        hyprctl keyword plugin:hyprscrolling:column_width 0.9
        ;;
    # Add more device-specific configs here:
    # another-device)
    #     hyprctl keyword input:sensitivity 0.5
    #     hyprctl keyword plugin:hyprscrolling:column_width 0.6
    #     ;;
esac
