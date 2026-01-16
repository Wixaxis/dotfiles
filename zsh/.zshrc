# Enable the subsequent settings only in interactive sessions
case $- in
  *i*) ;;
    *) return;;
esac

# Source the modular zsh configuration
if [ -f ~/.config/zsh/zshrc ]; then
  source ~/.config/zsh/zshrc
fi
