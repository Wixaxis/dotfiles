# Tmux Plugins Quick Reference

TLDR-style guide for all installed tmux plugins.

## Plugin Manager

### TPM (Tmux Plugin Manager)
- **Install plugins**: `prefix + I`
- **Update plugins**: `prefix + U`
- **Uninstall plugin**: Remove from `plugins.conf`, then `prefix + alt + u`

## Installed Plugins

### tmux-sensible
Basic tmux settings everyone can agree on. No keybindings - just works.

### tmux-which-key
- **Invoke**: `prefix + ?`
- Shows available keybindings in a popup menu
- Navigate with arrow keys or vim keys

### tmux-better-mouse-mode
Better mouse scrolling and selection. Just works - no keybindings.

### tmux-yank
- **Copy**: `prefix + y` (copy entire pane)
- **Copy selection**: In copy mode, select text then `y` to copy to system clipboard
- Works with `prefix + [` (copy mode)

### tmux-logging
- **Start logging**: `prefix + P` (capital P)
- **Stop logging**: `prefix + P` again
- **Screenshot**: `prefix + alt + p`
- Logs saved to `~/.tmux/logs/`

### tmux-autoreload
Automatically reloads tmux config when `tmux.conf` changes. No keybindings - just works.

### tmux-prefix-highlight
Shows visual indicator when prefix key is pressed. No keybindings - just works.

### tmux-fzf
- **Sessions**: `prefix + f s`
- **Windows**: `prefix + f w`
- **Panes**: `prefix + f p`
- **Processes**: `prefix + f k` (kill process)
- **History**: `prefix + f h` (command history)

### extracto
- **Invoke**: `prefix + tab` (in copy mode)
- Fuzzy select text from terminal output
- Filters: paths, URLs, git hashes, IPs, emails
- Navigate with fzf, select with Enter

## Quick Tips

- **Reload config manually**: `prefix + r` (from base.conf)
- **Copy mode**: `prefix + [` (enter), `q` (quit)
- **Paste**: `prefix + ]`
- **Prefix key**: `Ctrl-a` (configured in base.conf)
