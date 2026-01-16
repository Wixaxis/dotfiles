# macOS wrapper - sources the actual env from ~/.config/nushell/
# This is needed because nushell on macOS looks in ~/Library/Application Support/nushell/
# but we keep the actual config in ~/.config/nushell/ for cross-platform compatibility

source ~/.config/nushell/env.nu
