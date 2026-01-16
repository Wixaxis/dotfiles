# Oh My Zsh configuration
# This must be loaded early as other modules may depend on it

export ZSH="$HOME/.oh-my-zsh"
# No theme - using Starship instead (configured in 1-starship.zsh)
ZSH_THEME=""
plugins=(git zsh-autosuggestions sudo web-search copyfile dirhistory)
source $ZSH/oh-my-zsh.sh
