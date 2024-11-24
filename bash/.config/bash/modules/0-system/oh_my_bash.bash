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
source "$OSH"/oh-my-bash.sh
