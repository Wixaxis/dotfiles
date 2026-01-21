# Custom functions

# Universal package update function
# Tries available package managers in order of preference
u() {
    # Try arch-update first (if available)
    if command -v arch-update &> /dev/null; then
        arch-update
        return $?
    fi
    
    # Try paru (AUR helper)
    if command -v paru &> /dev/null; then
        paru -Syu
        return $?
    fi
    
    # Try yay (AUR helper)
    if command -v yay &> /dev/null; then
        yay -Syu
        return $?
    fi
    
    # Try pacman (Arch Linux)
    if command -v pacman &> /dev/null; then
        sudo pacman -Syu
        return $?
    fi
    
    # Try brew (macOS)
    if command -v brew &> /dev/null; then
        brew update && brew upgrade -g
        return $?
    fi
    
    # No package manager found
    echo "Error: No supported package manager found (arch-update, paru, yay, pacman, or brew)" >&2
    return 1
}

# Universal package search function
# Tries available package managers in order of preference
# Usage: s <package-name>
# Unalias s if it exists (may be defined by oh-my-zsh or other configs)
unalias s 2>/dev/null || true
s() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: s <package-name>" >&2
        return 1
    fi
    
    # Try paru (AUR helper)
    if command -v paru &> /dev/null; then
        paru -Ss "$@"
        return $?
    fi
    
    # Try yay (AUR helper)
    if command -v yay &> /dev/null; then
        yay -Ss "$@"
        return $?
    fi
    
    # Try pacman (Arch Linux)
    if command -v pacman &> /dev/null; then
        pacman -Ss "$@"
        return $?
    fi
    
    # Try brew (macOS)
    if command -v brew &> /dev/null; then
        brew search "$@"
        return $?
    fi
    
    # No package manager found
    echo "Error: No supported package manager found (paru, yay, pacman, or brew)" >&2
    return 1
}

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
