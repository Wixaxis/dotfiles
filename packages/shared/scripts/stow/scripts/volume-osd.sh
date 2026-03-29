#!/bin/bash
# Volume OSD - uses wob if available, otherwise creates a better notification
# Uses pactl directly to avoid volumectl notifications

# Get volume and mute status
get_volume() {
    pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oP '\d+(?=%)' | head -1 || echo "0"
}

get_mute() {
    pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -o "yes\|no" || echo "no"
}

# Handle volume commands using pactl directly (avoids volumectl notifications)
case "$1" in
    up)
        pactl set-sink-volume @DEFAULT_SINK@ +2% 2>/dev/null
        ;;
    down)
        pactl set-sink-volume @DEFAULT_SINK@ -2% 2>/dev/null
        ;;
    toggle)
        pactl set-sink-mute @DEFAULT_SINK@ toggle 2>/dev/null
        ;;
    *)
        # For other commands, fall back to volumectl but suppress output
        volumectl "$@" > /dev/null 2>&1
        exit $?
        ;;
esac

# Wait a moment for volume to update
sleep 0.1

volume=$(get_volume)
muted=$(get_mute)

# Use wob if available (via FIFO)
WOBCONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/wob/config.ini"
WOBPIPE="/tmp/wobpipe"

if command -v wob &> /dev/null; then
    # Ensure wob is running (start it if not)
    if ! pgrep -x wob > /dev/null; then
        # Create FIFO if it doesn't exist
        [ -p "$WOBPIPE" ] || mkfifo "$WOBPIPE" 2>/dev/null
        # Start wob in background
        if [ -f "$WOBCONFIG" ]; then
            tail -f "$WOBPIPE" | wob -c "$WOBCONFIG" > /dev/null 2>&1 &
        else
            tail -f "$WOBPIPE" | wob > /dev/null 2>&1 &
        fi
        sleep 0.2  # Give wob time to start
    fi
    
    # Send value to wob via FIFO (with timeout to prevent blocking)
    if [ -p "$WOBPIPE" ]; then
        if [ "$muted" = "yes" ]; then
            timeout 0.1 bash -c "echo '0' > '$WOBPIPE'" 2>/dev/null || true
        else
            timeout 0.1 bash -c "echo '$volume' > '$WOBPIPE'" 2>/dev/null || true
        fi
    fi
else
    # Fallback: Better notification WITHOUT progress bar
    if [ "$muted" = "yes" ]; then
        notify-send -t 800 -h string:synchronous:volume "🔇 Muted" "" 2>/dev/null
    else
        # Get appropriate icon based on volume level
        if [ "$volume" -ge 70 ]; then
            icon="🔊"
        elif [ "$volume" -ge 30 ]; then
            icon="🔉"
        else
            icon="🔈"
        fi
        # Don't use int:value to avoid the progress bar
        notify-send -t 800 -h string:synchronous:volume "$icon Volume" "$volume%" 2>/dev/null
    fi
fi
