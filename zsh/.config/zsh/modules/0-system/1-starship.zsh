# Starship prompt configuration
# Cross-shell prompt that follows Nord theme (consistent with Nushell)

# Initialize starship for interactive shells (starship is assumed to be installed)
if [[ -o interactive ]] && [[ "$TERM" != "dumb" ]]; then
    eval "$(starship init zsh)"
fi
