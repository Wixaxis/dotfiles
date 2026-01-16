# Aliases Summary Across Shell Configurations

This document lists all aliases currently defined across bash, zsh, and nushell configurations.

## Common Aliases (Present in Multiple Shells)

### File Operations

| Alias | Bash | Zsh | Nushell | Description |
|-------|------|-----|---------|-------------|
| `mux` | ✅ | ✅ | ✅ | Shortcut for `tmuxinator` |
| `mv` | ✅ (`mv -i`) | ❌ | ✅ (`mv -i`) | Interactive move (ask before overwriting) |
| `rm` | ✅ (trash) | ❌ | ✅ (trash) | Safe delete using trash-cli |
| `vim` | ✅ | ❌ | ❌ | Alias to `nvim` |

### Directory Listing

| Alias | Bash | Zsh | Nushell | Description |
|-------|------|-----|---------|-------------|
| `ls` | ✅ (exa/eza) | ✅ (eza) | ❌ | Enhanced ls with icons/colors |
| `ll` | ❌ | ✅ (eza) | ❌ | Long format listing |
| `la` | ❌ | ✅ (eza) | ❌ | All files (including hidden) |
| `lla` | ❌ | ✅ (eza) | ❌ | All files with long format |
| `lt` | ❌ | ✅ (eza) | ❌ | Tree view (level 2) |
| `ltt` | ❌ | ✅ (eza) | ❌ | Tree view (level 3) |
| `ltm` | ❌ | ✅ (eza) | ❌ | Sort by modified time |
| `lts` | ❌ | ✅ (eza) | ❌ | Sort by size |
| `lsa` | ✅ (exa) | ❌ | ✅ (def) | List all sorted by modified (newest first) |
| `lst` | ✅ (exa) | ❌ | ❌ | Tree view with exa |
| `lsta` | ✅ (exa) | ❌ | ❌ | Tree view all with exa |

### Terminal

| Alias | Bash | Zsh | Nushell | Description |
|-------|------|-----|---------|-------------|
| `reset` | ✅ | ❌ | ✅ (zsh -c) | Reset terminal and clear |
| `reload` | ✅ | ❌ | ❌ | Reload shell config |

## Shell-Specific Aliases

### Bash Only

| Alias | Location | Description |
|-------|----------|-------------|
| `wget` | `wget.bash` | Wget with XDG data home for HSTS |
| `gradience-cli` | `theming.bash` | Flatpak wrapper for gradience-cli |
| `go_nord` | `tmp.bash` | Python script for image processing |

### Zsh Only

| Alias | Location | Description |
|-------|----------|-------------|
| All `eza` aliases | `5-aliases.zsh` | Comprehensive eza-based listing aliases |

### Nushell Only

| Alias/Def | Location | Description |
|-----------|----------|-------------|
| `lsa` (def) | `aliases.nu` | List all sorted by modified (reverse) |
| `trash` (def) | `aliases.nu` | Platform-aware trash wrapper function |
| `get trash path` (def) | `aliases.nu` | Helper to find trash binary |

## Detailed Breakdown by Shell

### Bash Aliases

**Location**: `bash/.config/bash/modules/0-system/aliases.bash`

```bash
# Safe file operations
rm='trash' (if trash available) or 'rm -i' (fallback)
mv='mv -i'
mux=tmuxinator
reset='reset && clear'
lsa='exa --color=always --icons -la --sort=modified --reverse' (if exa available)
```

**Additional Bash Aliases**:
- `vim=nvim` (in `nvim.bash`)
- `mux=tmuxinator` (also in `tmux.bash`)
- `reload='source ~/.bashrc'` (in `bash.bash`)
- `wget='wget --hsts-file="$XDG_DATA_HOME/wget-hsts"'` (in `wget.bash`)
- `gradience-cli='flatpak run --command=gradience-cli ...'` (in `theming.bash`)
- `go_nord='python ~/scripts/python/image-go-nord-cli.py $@'` (in `tmp.bash`)

**Exa aliases** (in `ls_exa.bash`):
- `ls='exa --color=always --icons'`
- `lsa='exa --color=always --icons -la'` (basic, overridden by aliases.bash)
- `lst='exa --color=always --icons -T -L=2'`
- `lsta='exa --color=always --icons -T -L=2 -a'`

### Zsh Aliases

**Location**: `zsh/.config/zsh/modules/0-system/5-aliases.zsh`

```zsh
# tmuxinator shortcut
mux=tmuxinator

# eza aliases (if eza available)
ls='eza --icons --color=always --group-directories-first'
ll='eza --long --icons --color=always --group-directories-first --header --git'
la='eza --all --icons --color=always --group-directories-first'
lla='eza --all --long --icons --color=always --group-directories-first --header --git'
lt='eza --tree --icons --color=always --group-directories-first --level=2'
ltt='eza --tree --icons --color=always --group-directories-first --level=3'
ltm='eza --long --icons --color=always --group-directories-first --header --git --sort=modified --reverse'
lts='eza --long --icons --color=always --group-directories-first --header --git --sort=size --reverse'

# Fallback (if eza not available)
ls='ls --color=auto'
ll='ls -lh'
la='ls -A'
lla='ls -lAh'
```

### Nushell Aliases

**Location**: `nushell/.config/nushell/sources/aliases.nu`

```nushell
# Functions
def lsa [] { ls -a | sort-by modified | reverse }

# Aliases
alias mux = tmuxinator
alias reset = zsh -c 'reset && exit'
alias rm = trash  # Uses trash function
alias mv = mv -i

# Platform-aware trash function
def "get trash path" [] { ... }
def trash [...rest] { ... }
```

## Missing Aliases (Not Synced)

### Should be in all shells but missing:

1. **`mv='mv -i'`** - Missing in Zsh
2. **`rm='trash'`** - Missing in Zsh
3. **`vim=nvim`** - Missing in Zsh and Nushell
4. **`reload`** - Missing in Zsh and Nushell
5. **`reset`** - Missing in Zsh (present in Bash and Nushell)

### Shell-specific that might be useful elsewhere:

1. **Zsh eza aliases** (`ll`, `la`, `lla`, `lt`, `ltt`, `ltm`, `lts`) - Could be ported to Bash
2. **Bash exa aliases** (`lst`, `lsta`) - Could be ported to Zsh
3. **Nushell `lsa` function** - Already exists in Bash, could be added to Zsh

## Recommendations for Syncing

1. **Core aliases to sync across all shells:**
   - `mux=tmuxinator` ✅ (already synced)
   - `mv='mv -i'` (add to Zsh)
   - `rm='trash'` (add to Zsh, ensure trash-cli available)
   - `vim=nvim` (add to Zsh and Nushell)
   - `reset` (add to Zsh, adjust for shell)
   - `reload` (add to Zsh and Nushell, adjust for shell)

2. **Directory listing aliases:**
   - Standardize on `eza` (Zsh already uses it)
   - Port Zsh's comprehensive eza aliases to Bash
   - Consider adding basic `ls` aliases to Nushell if needed

3. **Platform-specific aliases:**
   - Keep Linux-only aliases (like `gradience-cli`, `wget` XDG) in Bash only
   - Keep macOS-specific paths/platform checks where needed
