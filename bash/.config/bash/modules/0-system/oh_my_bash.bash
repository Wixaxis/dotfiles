export OSH="/usr/share/oh-my-bash"
# Disable theme if starship is available (starship will handle the prompt)
if command -v starship &> /dev/null; then
    OSH_THEME=""  # Empty theme - starship will provide the prompt
else
    OSH_THEME="simple"
fi
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
source "$OSH"/oh-my-bash.sh
