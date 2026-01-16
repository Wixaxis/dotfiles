# Starship prompt configuration
# Cross-shell prompt that follows Nord theme (consistent with Nushell and Zsh)

# Initialize starship for interactive shells (starship is assumed to be installed)
if [[ $- == *i* ]]; then
    # Only skip if TERM is explicitly set to "dumb"
    if [[ -z "${TERM:-}" ]] || [[ "$TERM" != "dumb" ]]; then
        # Initialize Starship for Bash
        eval "$(starship init bash)"
        
        # Set starship shell identifier
        export STARSHIP_SHELL="bash"
    fi
fi
