# Exa (modern ls replacement) aliases
if command -v exa &> /dev/null; then
    alias ls='exa --color=always --icons'
    # lsa is defined in aliases.bash with sorting by modified time
    # This provides the basic version if aliases.bash hasn't loaded yet
    alias lsa='exa --color=always --icons -la'
    alias lst='exa --color=always --icons -T -L=2'
    alias lsta='exa --color=always --icons -T -L=2 -a'
else
    # Fallback to standard ls if exa not available
    alias ls='ls --color=auto'
    alias lsa='ls -la'
fi
