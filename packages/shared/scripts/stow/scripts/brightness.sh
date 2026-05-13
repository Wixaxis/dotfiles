#!/bin/bash
# External monitor brightness control via ddcutil
# Replaces brightness.rb

set -euo pipefail

STORE_FILE="$HOME/scripts/stored_brightness.txt"

get_current() {
    ddcutil -d 1 getvcp 10 2>/dev/null | grep -oP 'current value\s*=\s*\K\d+' || echo "0"
}

set_value() {
    local val="$1"
    ddcutil -d 1 setvcp 10 "$val" --noverify --disable-dynamic-sleep --sleep-multiplier .2 >/dev/null 2>&1 || true
}

store() {
    get_current > "$STORE_FILE"
}

restore() {
    if [[ -f "$STORE_FILE" ]]; then
        set_value "$(cat "$STORE_FILE")"
    fi
}

my_clamp() {
    local val="$1"
    if (( val < 0 )); then echo 0; elif (( val > 100 )); then echo 100; else echo "$val"; fi
}

# Parse operation
op="="
if [[ $# -ge 1 ]]; then
    case "$1" in
        +|increase|add|plus) op="+" ;;
        -|decrease|subtract|minus) op="-" ;;
        \?|get|check) op="?" ;;
        \!|sync|synchronize) op="!" ;;
        min) op="min" ;;
        max) op="max" ;;
        dim) op="dim" ;;
        restore) op="restore" ;;
    esac
fi

case "$op" in
    \?)
        echo "$(get_current)%"
        ;;
    \!)
        store
        ;;
    min)
        set_value 0
        store
        ;;
    max)
        set_value 100
        store
        ;;
    dim)
        set_value 0
        ;;
    restore)
        restore
        ;;
    +)
        step="${2:-10}"
        curr=$(get_current)
        new_val=$(my_clamp $(( curr + step )))
        set_value "$new_val"
        store
        ;;
    -)
        step="${2:-10}"
        curr=$(get_current)
        new_val=$(my_clamp $(( curr - step )))
        set_value "$new_val"
        store
        ;;
    *)
        # Set to specific value
        val="${1:-100}"
        new_val=$(my_clamp "$val")
        set_value "$new_val"
        store
        ;;
esac
