# Starship prompt configuration
# Ported from nushell prompt.nu

if command -v starship &> /dev/null; then
    # Initialize starship for bash
    eval "$(starship init bash)"
    
    # Set starship shell identifier
    export STARSHIP_SHELL="bash"
else
    # Fallback message if starship not installed
    [ "${DEBUG:-false}" = "true" ] && echo "Starship not found. Install with: cargo install starship"
fi
