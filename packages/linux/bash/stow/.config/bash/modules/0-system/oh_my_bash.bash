# Skip oh-my-bash entirely if starship is available
# Starship will be initialized in z-starship.bash which loads after this file
# oh-my-bash can interfere with starship's prompt even with empty theme
if ! command -v starship &> /dev/null; then
    # Only use oh-my-bash if starship is not available
    export OSH="/usr/share/oh-my-bash"
    OSH_THEME="simple"
    ENABLE_CORRECTION="true"
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
    
    # Only source oh-my-bash if it exists
    if [[ -f "$OSH/oh-my-bash.sh" ]]; then
        source "$OSH"/oh-my-bash.sh
    fi
fi
