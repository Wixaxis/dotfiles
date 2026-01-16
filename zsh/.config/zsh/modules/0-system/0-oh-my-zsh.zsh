# Oh My Zsh configuration
# This must be loaded early as other modules may depend on it

export ZSH="$HOME/.oh-my-zsh"
# No theme - using Starship instead (configured in 1-starship.zsh)
ZSH_THEME=""
plugins=(git zsh-autosuggestions sudo web-search copyfile dirhistory)

# Only source oh-my-zsh if it's installed
if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
    source "$ZSH/oh-my-zsh.sh"
else
    # Oh My Zsh not installed - provide basic functionality
    # Install with: sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    [[ "$DEBUG" == "true" ]] && echo "Oh My Zsh not found at $ZSH"
fi
