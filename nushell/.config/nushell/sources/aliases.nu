# Enhanced aliases - uniform across all shells

# Editor aliases
alias vim = nvim

# Platform-aware trash function
# macOS: uses system /usr/bin/trash (built-in)
# Linux: uses trash-cli package
def "get trash path" [] {
  # macOS system trash (built-in, always available)
  if ("/usr/bin/trash" | path exists) {
    "/usr/bin/trash"
  # Linux: check for trash-cli in common locations
  } else if ("/usr/bin/trash" | path exists) {
    "/usr/bin/trash"
  } else if (which trash | is-not-empty) {
    (which trash | get path.0)
  } else {
    "trash"  # Fallback to PATH
  }
}

# Wrapper function for platform-aware trash
def trash [...rest] {
  let trash_bin = (get trash path)
  ^$trash_bin ...$rest
}

# Safe file operations with trash
alias rm = trash
alias mv = trash  # Move to trash instead of moving files

# Enhanced ls using nushell's built-in ls
# Nushell's built-in ls is already excellent with colors, icons, and structured data
def lsa [] { ls -a | sort-by modified | reverse }
def lst [] { ls | tree -L 2 }
def lsta [] { ls -a | tree -L 2 }

# Directory navigation aliases
# Nushell supports these directly as commands
def --env ".." [] { cd .. }
def --env "..." [] { cd ../.. }
def --env "...." [] { cd ../../.. }

# Reset and reload - OS-aware (use bash on Linux, zsh on macOS)
def reset [] {
  if ($nu.os-info.name == "linux") {
    bash -c "reset && clear"
  } else {
    zsh -c "reset && clear"
  }
}

def reload [] {
  if ($nu.os-info.name == "linux") {
    bash -c "source ~/.bashrc"
  } else {
    zsh -c "source ~/.zshrc"
  }
}

# tmuxinator shortcut
alias mux = tmuxinator

# LazyGit shortcut
alias lg = lazygit

# Cursor Agent shortcut
alias ca = cursor-agent

# mise run shortcut
alias mr = mise run

# Universal package update function
# Tries available package managers in order of preference
def u [] {
    # Try arch-update first (if available)
    if (which arch-update | is-not-empty) {
        ^arch-update
    } else if (which paru | is-not-empty) {
        # Try paru (AUR helper)
        ^paru -Syu
    } else if (which yay | is-not-empty) {
        # Try yay (AUR helper)
        ^yay -Syu
    } else if (which pacman | is-not-empty) {
        # Try pacman (Arch Linux)
        ^sudo pacman -Syu
    } else if (which brew | is-not-empty) {
        # Try brew (macOS)
        ^brew update; ^brew upgrade -g
    } else {
        # No package manager found
        print "Error: No supported package manager found (arch-update, paru, yay, pacman, or brew)"
    }
}

# Universal package search function
# Tries available package managers in order of preference
# Usage: s <package-name>
def s [...package: string] {
    if ($package | is-empty) {
        print "Usage: s <package-name>"
        return
    }
    
    # Try paru (AUR helper)
    if (which paru | is-not-empty) {
        ^paru -Ss ...$package
    } else if (which yay | is-not-empty) {
        # Try yay (AUR helper)
        ^yay -Ss ...$package
    } else if (which pacman | is-not-empty) {
        # Try pacman (Arch Linux)
        ^pacman -Ss ...$package
    } else if (which brew | is-not-empty) {
        # Try brew (macOS)
        ^brew search ...$package
    } else {
        # No package manager found
        print "Error: No supported package manager found (paru, yay, pacman, or brew)"
    }
}

# File finding functions (using fzf)
if (which fzf | is-not-empty) {
  # Find files in current directory
  def ff [] {
    if (which fd | is-not-empty) {
      ^fd . | ^fzf
    } else {
      ^find . -type f | ^fzf
    }
  }
  
  # Find file by name (interactive)
  def ffn [...pattern: string] {
    if (which fd | is-not-empty) {
      if ($pattern | is-empty) {
        ^fd --type f | ^fzf
      } else {
        ^fd --type f ...$pattern | ^fzf
      }
    } else {
      if ($pattern | is-empty) {
        ^find . -type f | ^fzf
      } else {
        ^find . -type f -name $"*($pattern | str join)*" | ^fzf
      }
    }
  }
  
  # Find file by content (using ripgrep and fzf)
  def ffc [...query: string] {
    if (which rg | is-not-empty) {
      if ($query | is-empty) {
        print "Usage: ffc <search-query>"
        return
      }
      let query_str = ($query | str join " ")
      ^rg --files-with-matches --color=always $query_str | ^fzf --preview $"rg --color=always --line-number '{}' '($query_str)'"
    } else {
      print "Error: ripgrep (rg) is required for ffc"
    }
  }
}
