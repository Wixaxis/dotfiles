if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions sudo web-search copyfile dirhistory)
source $ZSH/oh-my-zsh.sh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

alias mux=tmuxinator

qa() {
  local host_number token bw_status

  if [[ "$(pwd)" != *activenow* ]]; then
    echo "qa: Must be run from activenow app directory" >&2
    return 1
  fi

  if [[ -z "$1" ]]; then
    echo "qa: host number is required" >&2
    return 1
  fi
  host_number="$1"
  shift

  # macOS-specific: use apple keychain for SSH keys
  if [[ "$OSTYPE" == "darwin"* ]]; then
    ssh-add --apple-load-keychain 2>/dev/null
    if ! ssh-add -l >/dev/null 2>&1 || ! ssh-add -l 2>/dev/null | grep -q 'id_ed25519'; then
      ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519" 2>/dev/null
    fi
  fi

  if [[ -z "$BW_SESSION" ]]; then
    bw_status="$(bw status 2>/dev/null | jq -r '.status')"
    case "$bw_status" in
      unauthenticated)
        token="$(bw login --raw | tr -d '\r\n')"
        ;;
      locked)
        token="$(bw unlock --raw | tr -d '\r\n')"
        ;;
      unlocked)
        token="$(bw unlock --raw | tr -d '\r\n')"
        ;;
    esac
    if [[ -n "$token" ]]; then
      export BW_SESSION="$token"
    else
      echo "qa: Bitwarden login/unlock failed" >&2
      return 1
    fi
  fi

  env BW_SESSION="$BW_SESSION" QA_NUMBER="$host_number" kamal "$@" -d qa
}

bw_env() {
  if [[ -z "$BW_SESSION" ]]; then
    bw_status="$(bw status 2>/dev/null | jq -r '.status')"
    case "$bw_status" in
      unauthenticated)
        token="$(bw login --raw | tr -d '\r\n')"
        ;;
      locked)
        token="$(bw unlock --raw | tr -d '\r\n')"
        ;;
      unlocked)
        token="$(bw unlock --raw | tr -d '\r\n')"
        ;;
    esac
    if [[ -n "$token" ]]; then
      export BW_SESSION="$token"
    else
      echo "qa: Bitwarden login/unlock failed" >&2
      return 1
    fi
  fi
}

eval "$(mise activate zsh)"
export PATH="$HOME/.local/bin:$PATH"
