# Config Analysis: Unstowed Configurations

## Summary

Found several configurations in `~/.config` that could potentially be stowed and added to the dotfiles repo.

## Good Candidates for Stowing

### 1. **fastfetch** (4KB) ✅ **RECOMMENDED**
- **Location**: `~/.config/fastfetch/config.jsonc`
- **Size**: 4KB
- **Content**: System info display configuration
- **Cross-platform**: Yes (works on macOS and Linux)
- **Recommendation**: ✅ **Add this** - Small, useful, cross-platform

### 2. **glow** (4KB) ✅ **RECOMMENDED**
- **Location**: `~/.config/glow/glow.yml`
- **Size**: 4KB
- **Content**: Markdown viewer configuration (style, mouse, pager, width settings)
- **Cross-platform**: Yes
- **Recommendation**: ✅ **Add this** - Small, useful, cross-platform

### 3. **cursor** (Partial) ⚠️ **CONDITIONAL**
- **Location**: `~/.config/cursor/`
- **Size**: 101MB total (but `cli-config.json` is only ~641 bytes)
- **Content**: 
  - `cli-config.json` - CLI configuration (small, useful)
  - `chats/` - Chat history (large, probably shouldn't be versioned)
- **Cross-platform**: Yes (Cursor works on macOS and Linux)
- **Recommendation**: ⚠️ **Add only `cli-config.json`** - Don't stow the entire directory due to size

### 4. **gh (GitHub CLI)** (8KB) ⚠️ **CONDITIONAL**
- **Location**: `~/.config/gh/`
- **Size**: 8KB
- **Content**: 
  - `config.yml` - GitHub CLI configuration (could be useful)
  - `hosts.yml` - Already in `.gitignore` (contains sensitive tokens)
- **Cross-platform**: Yes
- **Recommendation**: ⚠️ **Maybe add `config.yml`** - But check if it contains any sensitive info first

## Not Recommended

### 5. **nvim** (1.1MB) ❌
- **Reason**: Has its own `.git` repository - it's already version controlled separately
- **Recommendation**: Keep as separate repo

### 6. **raycast** (555MB) ❌
- **Reason**: Way too large, contains extensions and other runtime data
- **Recommendation**: Don't version control this

### 7. **asciinema** (4KB) ❌
- **Reason**: Only contains `install-id` - not useful to version
- **Recommendation**: Skip

### 8. **carapace** (0B) ❌
- **Reason**: Empty or auto-generated specs
- **Recommendation**: Skip

### 9. **helix** (0B) ❌
- **Reason**: Empty directory
- **Recommendation**: Skip

### 10. **opencode** (0B) ❌
- **Reason**: Empty directory
- **Recommendation**: Skip

### 11. **github-copilot** (8KB) ❌
- **Reason**: Contains runtime data (apps.json, versions.json) - not useful to version
- **Recommendation**: Skip

## Recommended Action Plan

1. **Add fastfetch** - Small, useful, cross-platform
2. **Add glow** - Small, useful, cross-platform  
3. **Add cursor (cli-config.json only)** - Useful CLI config, but exclude chats/
4. **Review gh/config.yml** - Check for sensitive info, then decide

## Implementation Steps

If you want to add these:

```bash
# 1. Create fastfetch package
mkdir -p fastfetch/.config/fastfetch
cp ~/.config/fastfetch/config.jsonc fastfetch/.config/fastfetch/
stow -t ~ fastfetch

# 2. Create glow package
mkdir -p glow/.config/glow
cp ~/.config/glow/glow.yml glow/.config/glow/
stow -t ~ glow

# 3. Create cursor package (cli-config.json only)
mkdir -p cursor/.config/cursor
cp ~/.config/cursor/cli-config.json cursor/.config/cursor/
# Add cursor/.config/cursor/chats/ to .gitignore
stow -t ~ cursor

# 4. Review and optionally add gh
# First check config.yml for sensitive info
cat ~/.config/gh/config.yml
# If safe, create package
mkdir -p githubcli/.config/gh
cp ~/.config/gh/config.yml githubcli/.config/gh/
# hosts.yml is already in .gitignore
stow -t ~ githubcli
```

## Update stow-platform.sh

After adding these, update `stow-platform.sh` to include them in the appropriate package lists:
- `fastfetch` → COMMON_PACKAGES
- `glow` → COMMON_PACKAGES
- `cursor` → COMMON_PACKAGES (macOS/Linux)
- `githubcli` → COMMON_PACKAGES (if you add it)
