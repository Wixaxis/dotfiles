# Branch Analysis: macos vs main

## Executive Summary

**Current Status**: You're on the `macos` branch with 485 tracked files. The `main` branch has 15,258 files and appears to be a unified cross-platform branch with platform-aware scripts.

**Overall Assessment**: The `main` branch is **mostly safe to switch to**, but there are **several macOS-specific issues** that need to be addressed before switching. The main branch has good platform detection in most places, but some hardcoded paths and configurations need fixing.

## Key Differences

### 1. Repository Structure

**macos branch** (current):
- 485 files
- 10 directories: ghostty, lazygit, neofetch, neovide, nushell, papes, starship, tmux, yazi, zsh
- Minimal, macOS-focused

**main branch**:
- 15,258 files (includes many archived configs, themes, and Linux-specific packages)
- 25+ directories including: bash, hyprland, rofi, swaync, waybar, btop, qt6ct, scripts, etc.
- Comprehensive cross-platform setup

### 2. Platform-Aware Scripts (main branch only)

The main branch includes:
- **`stow-platform.sh`**: Automatically detects platform (Linux/macOS/Wayland) and stows only relevant packages
- **`setup.sh`**: Comprehensive interactive setup script for both Arch and macOS
- **`justfile/justfile`**: Task runner with OS detection (defaults to Linux, can override with `OS=macOS`)

### 3. Critical Configuration Differences

#### ✅ **GOOD - Already Platform-Aware in main branch:**

1. **`zsh/.fzf.zsh`**: Main branch has proper macOS/Linux detection
2. **`zsh/.zshrc`**: Main branch wraps macOS-specific SSH keychain code in `[[ "$OSTYPE" == "darwin"* ]]` check
3. **`nushell/Library/Application Support/nushell/config.nu`**: Main branch has cleaner macOS wrapper that sources the main config

#### ⚠️ **ISSUES - Need Fixing in main branch:**

1. **`nushell/.config/nushell/modules/mise.nu`**:
   - **Problem**: Uses hardcoded `/usr/sbin/mise` (Linux path)
   - **Current macos branch**: Uses `/opt/homebrew/bin/mise`
   - **Fix needed**: Platform detection to use `/opt/homebrew/bin/mise` on macOS

2. **`nushell/.config/nushell/sources/aliases.nu`**:
   - **Problem**: Hardcoded `/opt/homebrew/opt/trash-cli/bin/trash`
   - **Fix needed**: Platform-aware path or conditional alias

3. **`ghostty/.config/ghostty/config`**:
   - **Main branch**: Has `# command = /opt/homebrew/bin/nu` commented out
   - **macos branch**: Has `command = /opt/homebrew/bin/nu` active
   - **Note**: This might be intentional (commented for cross-platform), but you may want it active on macOS

4. **`tmux/.config/tmux/conf.d/base.conf`**:
   - **Main branch**: Removed `set -g default-shell "/opt/homebrew/bin/nu"`
   - **macos branch**: Has this line
   - **Fix needed**: Platform-aware shell detection or conditional config

5. **`nushell/.config/nushell/envs/path.nu`**:
   - **Main branch**: Generic, relies on mise for PATH management
   - **macos branch**: Has explicit macOS Homebrew paths (`/opt/homebrew/bin`, `/opt/homebrew/sbin`, etc.)
   - **Note**: This might be okay if mise handles it, but you should verify

6. **`nushell/.config/nushell/env.nu`**:
   - **Main branch**: Removed several AI-related env files (gemini.nu, open_ai.nu, openrouter.nu, tavily.nu)
   - **macos branch**: Has these files
   - **Action needed**: Decide if you want these on all platforms or just macOS

### 4. Missing from main branch (macos branch has):

- AI-related nushell env files: `gemini.nu`, `open_ai.nu`, `openrouter.nu`, `tavily.nu`
- Active ghostty command pointing to nushell
- Active tmux default-shell setting
- Explicit macOS Homebrew paths in nushell path.nu

### 5. New in main branch (not in macos):

- Comprehensive documentation (README.md, SETUP_GUIDE.md, UNTRACKED_CONFIGS.md)
- Platform-aware stow script (`stow-platform.sh`)
- Comprehensive setup script (`setup.sh`)
- Bash configuration (modular, well-organized)
- Linux-specific packages (hyprland, waybar, swaync, btop, etc.)
- Archived configurations directory
- Justfile for task automation
- Scripts directory with Ruby scripts
- Device-specific config handling

## What's Currently Stowed (macos branch)

Based on symlink analysis, these packages are currently stowed:
- ✅ neovide
- ✅ neofetch
- ✅ lazygit
- ✅ starship
- ✅ nushell (both `.config/nushell` and `Library/Application Support/nushell`)
- ✅ yazi
- ✅ tmux
- ✅ ghostty
- ✅ zsh (`.zshrc`, `.p10k.zsh`, `.fzf.zsh`)
- ✅ papes (wallpapers)

## Safety Assessment for Switching to main

### ✅ **SAFE to switch:**
- The main branch has platform detection in most critical places
- The `stow-platform.sh` script will only stow macOS-relevant packages
- Most configuration files are compatible or have platform checks

### ⚠️ **REQUIRES ATTENTION before/after switching:**

1. **Before switching**: 
   - Backup your current working configuration
   - Note any custom changes you've made

2. **After switching**:
   - Run `./stow-platform.sh` to restow packages with platform detection
   - Fix the hardcoded paths in:
     - `nushell/.config/nushell/modules/mise.nu` (mise path)
     - `nushell/.config/nushell/sources/aliases.nu` (trash path)
   - Decide on:
     - Whether to restore AI-related nushell env files
     - Whether to uncomment ghostty command for macOS
     - Whether to add platform-aware tmux default-shell

3. **Test thoroughly**:
   - Verify nushell works correctly
   - Verify mise integration works
   - Verify zsh configuration loads properly
   - Check that all stowed symlinks are correct

## Recommended Migration Steps

1. **Create a backup branch**:
   ```bash
   git branch macos-backup
   ```

2. **Switch to main**:
   ```bash
   git checkout main
   git pull origin main
   ```

3. **Unstow current packages** (optional, but clean):
   ```bash
   stow -D -t ~ ghostty lazygit neofetch neovide nushell papes starship tmux yazi zsh
   ```

4. **Run platform-aware stow**:
   ```bash
   ./stow-platform.sh
   ```

5. **Fix critical issues** (see fixes needed above)

6. **Test and verify** everything works

7. **Commit fixes** to main branch

## Files That Need Platform-Aware Fixes

### Priority 1 (Critical):
1. `nushell/.config/nushell/modules/mise.nu` - Fix mise path detection
2. `nushell/.config/nushell/sources/aliases.nu` - Fix trash path

### Priority 2 (Important):
3. `ghostty/.config/ghostty/config` - Consider uncommenting command for macOS
4. `tmux/.config/tmux/conf.d/base.conf` - Add platform-aware default-shell

### Priority 3 (Optional):
5. `nushell/.config/nushell/env.nu` - Decide on AI env files
6. `nushell/.config/nushell/envs/path.nu` - Verify mise handles all paths correctly

## Conclusion

The main branch is **well-designed for cross-platform use** and has good infrastructure (platform detection scripts, comprehensive setup). However, there are **several hardcoded paths that need to be made platform-aware** before it will work seamlessly on macOS.

**Recommendation**: Switch to main, but plan to fix the issues listed above immediately after switching. The infrastructure is solid, but some configuration details need macOS-specific handling.
