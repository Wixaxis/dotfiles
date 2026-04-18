# Neovim configuration

nvim() {
    NVIM_APPNAME=nvim command nvim "$@"
}

nvim_old() {
    NVIM_APPNAME=nvim_old command nvim "$@"
}

alias vim=nvim
export EDITOR=nvim
export VISUAL=nvim
export DIFFPROG='nvim -d $1'
