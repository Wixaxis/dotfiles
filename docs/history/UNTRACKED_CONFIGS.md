# Untracked Configs Analysis

This document lists configurations in `~/.config` that are not currently tracked in the dotfiles repository.

## Summary

**Total untracked configs:** ~40 directories

## Configs Worth Tracking

### High Priority

1. **qt6ct** (28K, 3 files)
   - Qt theming configuration (we just set this up!)
   - Contains: `qt6ct.conf`, `colors/`, `palettes/`
   - **Recommendation:** Add to dotfiles

2. **mise** (8K, 1 file)
   - mise configuration: `config.toml`
   - **Recommendation:** Add to dotfiles if you have custom mise settings

3. **flameshot** (8K, 1 file)
   - Screenshot tool configuration
   - **Recommendation:** Add if you have custom settings

### Medium Priority

4. **nvim** (936K, 115 files)
   - **Note:** Has its own `.git` directory - it's a separate git repository!
   - **Recommendation:** Keep as separate repo, or decide if you want to merge it

5. **gtk-3.0** (504K, 53 files)
   - GTK theme configuration
   - **Recommendation:** Add if you have custom GTK theme settings

6. **go** (84K, 13 files)
   - Go language configuration
   - **Recommendation:** Add if you use Go and have custom settings

7. **mpv** (4K, empty)
   - Media player config (currently empty)
   - **Recommendation:** Add when you configure it

## Configs NOT Worth Tracking

### Application Data/Cache (too large or auto-generated)

- **google-chrome** (124M, 925 files) - Browser cache/data
- **Cursor** (57M, 232 files) - IDE cache/data  
- **lunarclient** (391M, 48872 files) - Game client data
- **GIMP** (944K, 71 files) - Image editor (mostly cache)
- **fragments** (304K, 27 files) - App data
- **Proton Pass** (4M) - Password manager data (sensitive)

### System/Auto-Generated

- **dconf** - System settings (auto-generated)
- **pulse** - Audio system config (auto-generated)
- **systemd** - System services (auto-generated)
- **session** - Session data (auto-generated)
- **autostart** - Desktop autostart files (auto-generated)

### Small/Optional Tools

- carapace, nemo, nwg-look, openrazer, polychromatic
- peazip, qimgv, ristretto, sshpilot, Thunar
- xarchiver, xfce4, xsettingsd, yay, vicinae

## Issues Found

1. **gh** (githubcli) - Not stowed
   - `~/.config/gh` exists but is NOT a symlink
   - The `githubcli` package should create this symlink
   - **Action:** Check if `githubcli` package is stowed

2. **nvim** - Separate git repository
   - Has its own `.git` directory
   - Decide: Keep separate or merge into dotfiles?

## Recommendations

1. **Add qt6ct** - We just configured it, should be tracked
2. **Add mise config** - If you have custom settings
3. **Fix githubcli stowing** - Verify `gh` config is properly stowed
4. **Decide on nvim** - Keep as separate repo or merge?

## Next Steps

To add a config to dotfiles:
1. Create package directory: `mkdir -p <package>/.config/<config-name>`
2. Copy config: `cp -r ~/.config/<config-name> <package>/.config/`
3. Stow it: `stow -t ~ <package>`
4. Commit to git
