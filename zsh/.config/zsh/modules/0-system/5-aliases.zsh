# Aliases configuration

# tmuxinator shortcut
alias mux=tmuxinator

# Beautiful ls with eza (icons, colors, git status)
# eza is a modern replacement for ls with better colors and icons
# Output is still greppable (plain text with ANSI colors)
if command -v eza &> /dev/null; then
    # Basic ls with icons and colors
    alias ls='eza --icons --color=always --group-directories-first'
    
    # Long format with details
    alias ll='eza --long --icons --color=always --group-directories-first --header --git'
    
    # All files (including hidden)
    alias la='eza --all --icons --color=always --group-directories-first'
    
    # All files with long format
    alias lla='eza --all --long --icons --color=always --group-directories-first --header --git'
    
    # Tree view
    alias lt='eza --tree --icons --color=always --group-directories-first --level=2'
    
    # Tree view with more levels
    alias ltt='eza --tree --icons --color=always --group-directories-first --level=3'
    
    # Sort by modified time (newest first)
    alias ltm='eza --long --icons --color=always --group-directories-first --header --git --sort=modified --reverse'
    
    # Sort by size (largest first)
    alias lts='eza --long --icons --color=always --group-directories-first --header --git --sort=size --reverse'
else
    # Fallback to regular ls with colors if eza is not available
    alias ls='ls --color=auto'
    alias ll='ls -lh'
    alias la='ls -A'
    alias lla='ls -lAh'
fi
