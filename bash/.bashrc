# Enable the subsequent settings only in interactive sessions
case $- in
  *i*) ;;
    *) return;;
esac

[[ "$(whoami)" = "root" ]] && return

[[ -z "$FUNCNEST" ]] && export FUNCNEST=100

# Source the modular bash configuration
if [ -f ~/.config/bash/bashrc ]; then
  source ~/.config/bash/bashrc
fi

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/wixaxis/.lmstudio/bin"
# End of LM Studio CLI section

