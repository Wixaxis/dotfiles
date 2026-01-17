# Aliases configuration - uniform across all shells

# Editor aliases
alias vim=nvim

# Safe file operations with trash
# macOS: uses system /usr/bin/trash
# Linux: uses trash-cli package
if command -v trash &> /dev/null; then
    alias rm='trash'
    alias mv='trash'  # Move to trash instead of moving files
else
    # Fallback: make rm safer with confirmation
    alias rm='rm -i'
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Warning: trash-cli not found. Install it for safe file operations." >&2
    fi
fi

# Enhanced ls with eza (icons, colors, git status)
# eza is a modern replacement for ls with better colors and icons
# Output is still greppable (plain text with ANSI colors)
if command -v eza &> /dev/null; then
    # Basic ls with icons and colors
    alias ls='eza --icons --color=always --group-directories-first'
    
    # List all sorted by modified time (newest first)
    alias lsa='eza --all --icons --color=always --group-directories-first --sort=modified --reverse'
    
    # Tree view (level 2)
    alias lst='eza --tree --icons --color=always --group-directories-first --level=2'
    
    # Tree view all (level 2, including hidden)
    alias lsta='eza --tree --all --icons --color=always --group-directories-first --level=2'
else
    # Fallback to regular ls with colors if eza is not available
    alias ls='ls --color=auto'
    alias lsa='ls -la'
    alias lst='tree -L 2 2>/dev/null || find . -maxdepth 2 -print | sed -e "s;[^/]*/;|____;g;s;____|; |;g"'
    alias lsta='tree -a -L 2 2>/dev/null || find . -maxdepth 2 -print | sed -e "s;[^/]*/;|____;g;s;____|; |;g"'
fi

# Directory navigation aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Reload shell configuration
alias reload='source ~/.zshrc'

# tmuxinator shortcut
alias mux=tmuxinator

# LazyGit shortcut
alias lg=lazygit

# Cursor Agent shortcut
alias ca=cursor-agent

# File finding aliases (using fzf)
if command -v fzf &> /dev/null; then
    # Find files in current directory
    alias ff='fd . | fzf || find . -type f | fzf'
    
    # Find file by name (interactive)
    ffn() {
        if command -v fd &> /dev/null; then
            fd --type f "$@" | fzf
        else
            find . -type f -name "*$@*" | fzf
        fi
    }
    
    # Find file by content (using ripgrep and fzf)
    ffc() {
        if command -v rg &> /dev/null; then
            if [[ $# -eq 0 ]]; then
                echo "Usage: ffc <search-query>" >&2
                return 1
            fi
            local query="$*"
            rg --files-with-matches --color=always "$query" | fzf --preview "rg --color=always --line-number '{}' '$query'"
        else
            echo "Error: ripgrep (rg) is required for ffc" >&2
            return 1
        fi
    }
fi
