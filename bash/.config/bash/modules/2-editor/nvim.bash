alias vim=nvim
export EDITOR=nvim
export DIFFPROG="nvim -d $1"

# TODO: Not sure if works, fix if does not
#
# Neovim config switcher
# nvims() {
#   items=("default" "NvChad" "NvimKickstart")
#   config=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Neovim Config  " --height=~50% --layout=reverse --border --exit-0)
#   if [[ -z $config ]]; then
#     echo "Nothing selected"
#     return 0
#   elif [[ $config == "default" ]]; then
#     config=""
#   fi
#   NVIM_APPNAME=$config nvim $@
# }
#
# nvchad() { 
#   NVIM_APPNAME="NvChad" nvim $@ 
# }
