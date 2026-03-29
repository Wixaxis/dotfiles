# Setup fzf
# ---------
# Platform-aware fzf path detection
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS - Homebrew path
  if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
    PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
  fi
  FZF_BASE="/opt/homebrew/opt/fzf"
else
  # Linux - standard installation paths
  if [[ ! "$PATH" == *$HOME/.fzf/bin* ]] && [[ -d "$HOME/.fzf/bin" ]]; then
    PATH="${PATH:+${PATH}:}$HOME/.fzf/bin"
  fi
  FZF_BASE="${FZF_BASE:-$HOME/.fzf}"
fi

# Auto-completion
# ---------------
if [[ "$OSTYPE" == "darwin"* ]]; then
  [[ -f "/opt/homebrew/opt/fzf/shell/completion.zsh" ]] && source "/opt/homebrew/opt/fzf/shell/completion.zsh"
else
  [[ -f "$FZF_BASE/shell/completion.zsh" ]] && source "$FZF_BASE/shell/completion.zsh"
fi

# Key bindings
# ------------
if [[ "$OSTYPE" == "darwin"* ]]; then
  [[ -f "/opt/homebrew/opt/fzf/shell/key-bindings.zsh" ]] && source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
else
  [[ -f "$FZF_BASE/shell/key-bindings.zsh" ]] && source "$FZF_BASE/shell/key-bindings.zsh"
fi
