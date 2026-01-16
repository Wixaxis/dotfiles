# Nushell Cleanup Summary

## Changes Made

### 1. Removed Obsolete Modules ✅

**Deleted:**
- `nushell/.config/nushell/modules/rbenv.nu` - Old rbenv wrapper (replaced by mise)
- `nushell/.config/nushell/modules/scripts.nu` - Contained `ansi_compile` function (no longer needed)

**Updated:**
- `nushell/.config/nushell/config.nu` - Removed references to `scripts.nu` module

### 2. Made XDG Linux-Only ✅

**Rationale:**
- XDG Base Directory is a Linux standard
- macOS uses `~/Library/Application Support`, `~/Library/Preferences`, etc.
- Setting XDG on macOS can cause conflicts with macOS-native applications
- Better to keep platform conventions separate

**Changes:**
- `nushell/.config/nushell/envs/xdg.nu` - Now wrapped in `if ($nu.os-info.name == "linux")`
- `nushell/.config/nushell/env.nu` - Conditionally sources XDG only on Linux
- `bash/.config/bash/modules/0-system/0-xdg.bash` - Now wrapped in `if [[ "$OSTYPE" == "linux-gnu"* ]]`

**Result:**
- XDG variables are only set on Linux systems
- macOS systems use native macOS paths
- No conflicts or confusion

### 3. Kept Nushell-Specific Features ✅

**Retained (as requested):**
- **Carapace completions** - Nushell-specific completer, kept in nushell config
- **Starship prompt** - Both Nushell and Zsh use Starship (consistent across shells)

**Reasoning:**
- Carapace is designed for nushell's completion system
- Starship works great in nushell
- No need to port these to zsh (different shells, different tools)

## Files Modified

1. `nushell/.config/nushell/config.nu` - Removed `scripts.nu` reference
2. `nushell/.config/nushell/env.nu` - Made XDG conditional (Linux only)
3. `nushell/.config/nushell/envs/xdg.nu` - Wrapped in Linux check
4. `bash/.config/bash/modules/0-system/0-xdg.bash` - Made Linux-only

## Files Deleted

1. `nushell/.config/nushell/modules/rbenv.nu` - Obsolete
2. `nushell/.config/nushell/modules/scripts.nu` - Obsolete

## Verification

- ✅ Nushell config loads without errors
- ✅ mise still works correctly
- ✅ XDG only loads on Linux
- ✅ No references to removed modules remain

## Notes

- The `ansi_compile.rb` script file still exists in `nushell/.config/nushell/scripts/ruby/` but is no longer referenced
- You can delete it manually if desired, or leave it (it's harmless)
- All functionality has been preserved, just cleaned up
