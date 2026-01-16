# Oh My Zsh configuration
# This must be loaded early as other modules may depend on it

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions sudo web-search copyfile dirhistory)
source $ZSH/oh-my-zsh.sh
