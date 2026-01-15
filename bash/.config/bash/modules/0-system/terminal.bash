# Terminal detection and configuration
# Ported from nushell terminal settings

# Detect and set terminal
if [ -n "$TERM_PROGRAM" ]; then
    # macOS Terminal.app, iTerm2, etc.
    export TERMINAL="$TERM_PROGRAM"
elif [ -n "$WAYLAND_DISPLAY" ] || [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    # Wayland terminal detection
    if command -v ghostty &> /dev/null; then
        export TERMINAL="ghostty"
    elif [ -n "$TERM" ]; then
        export TERMINAL="$TERM"
    fi
elif [ -n "$TERM" ]; then
    # X11 or other
    export TERMINAL="$TERM"
fi

# Set TERMINAL to ghostty if available and not already set
if [ -z "$TERMINAL" ] && command -v ghostty &> /dev/null; then
    export TERMINAL="ghostty"
fi
