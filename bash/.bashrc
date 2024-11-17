# Enable the subsequent settings only in interactive sessions
case $- in
  *i*) ;;
    *) return;;
esac

export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"


export HISTFILE="$XDG_STATE_HOME/bash/history"
export OSH="/usr/share/oh-my-bash"

OSH_THEME="simple"

#Command auto-correction.
ENABLE_CORRECTION="true"
#Display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

HIST_STAMPS='[dd.mm.yyyy]'

OMB_USE_SUDO=true

completions=(
  git
  composer
  ssh
)

aliases=(
  general
)

plugins=(
  git
  bashmarks
)

source "$OSH"/oh-my-bash.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Compilation flags
export ARCHFLAGS="-arch x86_64"

alias ls='exa --color=always --icons'

[[ "$(whoami)" = "root" ]] && return

[[ -z "$FUNCNEST" ]] && export FUNCNEST=100          # limits recursive functions, see 'man bash'

_open_files_for_editing() {
    if [ -x /usr/bin/exo-open ] ; then
        echo "exo-open $@" >&2
        setsid exo-open "$@" >& /dev/null
        return
    fi
    if [ -x /usr/bin/xdg-open ] ; then
        for file in "$@" ; do
            echo "xdg-open $file" >&2
            setsid xdg-open "$file" >& /dev/null
        done
        return
    fi

    echo "$FUNCNAME: package 'xdg-utils' or 'exo' is required." >&2
}

export JAVA_HOME='/usr/lib/jvm/java-17-openjdk'
export PATH=$JAVA_HOME/bin:$PATH
export CHROME_EXECUTABLE="/var/lib/flatpak/exports/bin/com.google.Chrome"
export CHROME_PATH="/var/lib/flatpak/exports/bin/com.google.Chrome"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export XCURSOR_PATH="/usr/share/icons:$XDG_DATA_HOME/icons"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NUGET_PACKAGES="$XDG_CACHE_HOME/NuGetPackages"
export PYTHONSTARTUP="/etc/python/pythonrc"
export RBENV_ROOT="$XDG_DATA_HOME/rbenv"
export BUNDLE_USER_CONFIG="$XDG_CONFIG_HOME/bundle"
export BUNDLE_USER_CACHE="$XDG_CACHE_HOME/bundle"
export BUNDLE_USER_PLUGIN="$XDG_DATA_HOME/bundle"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export SOLARGRAPH_CACHE="$XDG_CACHE_HOME/solargraph"
export DOTNET_CLI_HOME="$XDG_DATA_HOME/dotnet"
export GOPATH="$XDG_DATA_HOME/go"
# export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java
# export BROWSER=min

alias wget=wget --hsts-file="$XDG_DATA_HOME/wget-hsts"

source /usr/share/fzf/completion.bash && source /usr/share/fzf/key-bindings.bash
source $HOME/scripts/bash/just.bash

alias lsa="exa --color=always --icons -la"
alias lst="exa --color=always --icons -T -L=2"
alias lsta="exa --color=always --icons -T -L=2 -a"

export DIFFPROG="nvim -d $1"
alias vim="nvim"

alias gradience-cli="flatpak run --command=gradience-cli com.github.GradienceTeam.Gradience"
alias go_nord="python ~/scripts/python/image-go-nord-cli.py $@"

eval "$(rbenv init - bash)"
# eval "$(rbenv rehash)"

export QT_STYLE_OVERRIDE=kvantum
# export ICON_THEME=Tela-nord-dark
# export GTK_THEME=Nordic-darker-v40
# export GTK_THEME=Adwaita-dark-nord

export PATH=$XDG_CONFIG_HOME/emacs/bin:$PATH
export PATH=/var/lib/flatpak/exports/bin:$PATH

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

# Reload bashrc
reload() {
  source ~/.bashrc
}
