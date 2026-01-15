# Enhanced aliases ported from nushell configuration

# Safe file operations
if command -v trash &> /dev/null; then
    alias rm='trash'
    alias trash='/opt/homebrew/opt/trash-cli/bin/trash 2>/dev/null || trash'
else
    # Fallback: make rm safer with confirmation
    alias rm='rm -i'
fi

# Interactive move (ask before overwriting)
alias mv='mv -i'

# Enhanced ls with exa (if available)
# Note: This overrides the basic lsa from ls_exa.bash with sorted version
if command -v exa &> /dev/null; then
    # lsa: list all sorted by modified time (reverse - newest first)
    # This provides the enhanced version from nushell config
    alias lsa='exa --color=always --icons -la --sort=modified --reverse'
fi

# Reset terminal (useful for clearing terminal state)
alias reset='reset && clear'

# tmuxinator shortcut (already in tmux.bash, but keeping for consistency)
alias mux=tmuxinator
