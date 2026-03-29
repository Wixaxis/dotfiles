# macOS wrapper - sources the actual config from ~/.config/nushell/
# This is needed because nushell on macOS looks in ~/Library/Application Support/nushell/
# but we keep the actual config in ~/.config/nushell/ for cross-platform compatibility

source ~/.config/nushell/config.nu
