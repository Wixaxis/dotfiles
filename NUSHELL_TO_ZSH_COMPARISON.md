# Nushell to Zsh Configuration Comparison

This document compares the nushell configuration with the current zsh setup to identify what might be missing.

## Summary

| Category | Nushell | Zsh | Status |
|----------|---------|-----|--------|
| **Aliases** | 5 aliases | 1 alias | ⚠️ Missing 4 |
| **Environment Variables** | 3 vars | 0 vars | ⚠️ Missing 3 |
| **Functions** | 3 functions | 2 functions | ⚠️ Missing 1 |
| **XDG Setup** | Full XDG | None | ⚠️ Missing |
| **Prompt** | Starship | Starship | ✅ Same (consistent across shells) |
| **Completions** | Carapace | Oh My Zsh | ✅ Different (both work) |

## Detailed Comparison

### 1. Aliases

#### ✅ Present in Both
- `mux = tmuxinator` ✓ (both have this)

#### ⚠️ Missing in Zsh

1. **`lsa` - Enhanced list command**
   ```nushell
   def lsa [] { ls -a | sort-by modified | reverse }
   ```
   - **Purpose**: Lists all files sorted by modification time (newest first)
   - **Zsh equivalent**: Could use `exa` or `ls` with sorting
   - **Recommendation**: ⭐ **Add this** - Useful for seeing recent files

2. **`rm = trash` - Safe delete**
   ```nushell
   alias rm = trash
   ```
   - **Purpose**: Use trash-cli instead of permanent delete
   - **Zsh equivalent**: Already in bash config, missing in zsh
   - **Recommendation**: ⭐ **Add this** - Prevents accidental deletions

3. **`mv = mv -i` - Interactive move**
   ```nushell
   alias mv = mv -i
   ```
   - **Purpose**: Ask before overwriting files
   - **Zsh equivalent**: Missing
   - **Recommendation**: ⭐ **Add this** - Safety feature

4. **`reset` - Terminal reset**
   ```nushell
   alias reset = zsh -c 'reset && exit'
   ```
   - **Purpose**: Reset terminal and exit (useful for clearing state)
   - **Zsh equivalent**: Missing
   - **Recommendation**: ⚠️ **Maybe add** - Niche use case

### 2. Environment Variables

#### ⚠️ Missing in Zsh

1. **`EDITOR` and `VISUAL`**
   ```nushell
   $env.EDITOR = 'nvim'
   $env.VISUAL = 'nvim'
   ```
   - **Purpose**: Default editor for various tools
   - **Zsh equivalent**: Missing
   - **Recommendation**: ⭐ **Add this** - Many tools use these

2. **`TERMINAL`**
   ```nushell
   $env.TERMINAL = 'ghostty'
   ```
   - **Purpose**: Identifies terminal emulator
   - **Zsh equivalent**: Missing
   - **Recommendation**: ⚠️ **Maybe add** - Some tools check this

### 3. Functions

#### ✅ Present in Both
- `qa()` - QA deployment function ✓
- `bw_env()` - Bitwarden environment setup ✓

#### ⚠️ Missing in Zsh

1. **`trash` - Platform-aware trash function**
   ```nushell
   def trash [...rest] {
     let trash_bin = (get trash path)
     ^$trash_bin ...$rest
   }
   ```
   - **Purpose**: Platform-aware wrapper for trash-cli
   - **Zsh equivalent**: Missing (bash has it, zsh doesn't)
   - **Recommendation**: ⭐ **Add this** - Needed for `rm = trash` alias

2. **`lsa` - Enhanced list function**
   - Already covered in aliases section
   - **Recommendation**: ⭐ **Add this**

### 4. XDG Base Directory Setup

#### ⚠️ Missing in Zsh

Nushell has comprehensive XDG Base Directory setup:
- `XDG_DATA_HOME`, `XDG_CONFIG_HOME`, `XDG_STATE_HOME`, `XDG_CACHE_HOME`
- `XDG_DESKTOP_DIR`, `XDG_DOCUMENTS_DIR`, `XDG_DOWNLOAD_DIR`, etc.
- Directory creation helpers
- Platform-aware paths (macOS vs Linux)

**Recommendation**: ⭐ **Add this** - Good practice for cross-platform compatibility

### 5. Prompt System

#### Nushell
- Uses **Starship** prompt
- Custom left and right prompts
- Platform-aware

#### Zsh
- Uses **Starship** (same as Nushell)
- Consistent prompt experience across shells

**Recommendation**: ✅ **Keep as-is** - Both shells use Starship for consistency

### 6. Completions

#### Nushell
- Uses **Carapace** completer
- Nushell-specific

#### Zsh
- Uses **Oh My Zsh** completions
- Zsh-specific

**Recommendation**: ✅ **Keep as-is** - Shell-specific, both work well

### 7. Modules/Features

#### Nushell-Specific (Not Applicable to Zsh)
- `ansi_compile` - Nushell-specific function
- `rbenv` module - Nushell wrapper
- `mise` module - Nushell-specific wrapper (zsh uses `eval "$(mise activate zsh)"`)

**Recommendation**: ✅ **Skip** - Nushell-specific, not needed in zsh

## Recommended Additions to Zsh

### Priority 1 (High Value)

1. **Editor environment variables**
   ```zsh
   export EDITOR='nvim'
   export VISUAL='nvim'
   ```

2. **Safe file operations aliases**
   ```zsh
   # Platform-aware trash
   if command -v trash &> /dev/null; then
       alias rm='trash'
   else
       alias rm='rm -i'  # Fallback to interactive
   fi
   alias mv='mv -i'
   ```

3. **Enhanced list alias**
   ```zsh
   # lsa - list all sorted by modified time (newest first)
   if command -v exa &> /dev/null; then
       alias lsa='exa --color=always --icons -la --sort=modified --reverse'
   elif command -v ls &> /dev/null; then
       alias lsa='ls -alt'
   fi
   ```

4. **XDG Base Directory setup**
   - Create module for XDG environment variables
   - Platform-aware directory creation

### Priority 2 (Nice to Have)

5. **TERMINAL environment variable**
   ```zsh
   export TERMINAL='ghostty'
   ```

6. **Reset alias** (if you use it)
   ```zsh
   alias reset='reset && clear'
   ```

## Implementation Plan

### Option 1: Add to Existing Modules

- **Aliases**: Add to `0-system/5-aliases.zsh`
- **Environment**: Create `0-system/7-env.zsh` (after mise, before functions)
- **XDG**: Create `0-system/0-xdg.zsh` (load first, before other modules)

### Option 2: Create New Modules

- `0-system/7-env.zsh` - Environment variables
- `0-system/8-xdg.zsh` - XDG Base Directory setup

## Files to Create/Modify

1. **Modify**: `zsh/.config/zsh/modules/0-system/5-aliases.zsh`
   - Add `lsa`, `rm = trash`, `mv = mv -i`, `reset`

2. **Create**: `zsh/.config/zsh/modules/0-system/7-env.zsh`
   - Add `EDITOR`, `VISUAL`, `TERMINAL`

3. **Create**: `zsh/.config/zsh/modules/0-system/0-xdg.zsh`
   - Full XDG Base Directory setup (port from nushell)

4. **Create**: Helper function for trash (if needed)
   - Could add to `5-aliases.zsh` or create separate `trash.zsh`

## Notes

- The bash config already has some of these (aliases, path), so we can reference it
- XDG setup is particularly useful for cross-platform compatibility
- Editor variables are used by many tools (git, etc.)
- Safe file operations (trash, interactive mv) prevent accidents
