def lsa [] { ls -a | sort-by modified | reverse }
alias mux = tmuxinator
alias reset = zsh -c 'reset && exit'

# Platform-aware trash function
def "get trash path" [] {
  # macOS Homebrew path
  if ("/opt/homebrew/opt/trash-cli/bin/trash" | path exists) {
    "/opt/homebrew/opt/trash-cli/bin/trash"
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

alias rm = trash
alias mv = mv -i
