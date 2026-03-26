# Config Audit: Missing vs No-Longer-Used Programs

Audit date: 2025-03-15. After config changes and recent pulls, these are the discrepancies.

---

## Hyprland bindings – programs referenced

From `bindings.conf` and `base_bindings.conf` (every `exec` command):

| Binding / key | Command / program | Package / note |
|---------------|-------------------|----------------|
| **Applications** | | |
| Super+Enter, Super+G | `vicinae app launch com.mitchellh.ghostty.desktop` | vicinae + ghostty |
| Super+W | `vicinae app launch google-chrome.desktop` | Chrome (external) |
| Super+T | `vicinae app launch org.telegram.desktop.desktop` | Telegram (external) |
| Super+A | `vicinae app launch opencode-desktop-electron.desktop` | **opencode** (desktop + CLI; tmuxinator, `oc` alias) |
| Super+O | `vicinae app launch thunar.desktop` | **thunar** (in stow) |
| Super+B | `vicinae app launch md.obsidian.Obsidian.desktop` | Obsidian (external) |
| Super+Space | `vicinae toggle` | **vicinae** |
| Super+Alt+Space | `vicinae vicinae://.../search-emojis` | vicinae |
| Super+Tab | `vicinae vicinae://.../switch-windows` | vicinae |
| Super+/ | `vicinae vicinae://.../hyprland-keybinds` | vicinae |
| Super+V | `cliphist list \| rofi -dmenu \| cliphist decode \| wl-copy` | **cliphist**, **rofi**, **wl-copy** |
| Super+J | `/home/wixaxis/scripts/quick-just.rb init` | **just**, **mise**, **ruby** (scripts) |
| **System** | | |
| Super+L | `hyprlock` | **hyprlock** (in setup.sh) |
| Super+N | `swaync-client -t` | **swaync** |
| Super+Shift+R | `hyprctl reload` | hyprland built-in |
| Super+Shift+E | `/home/wixaxis/scripts/powermenu.rb init` | scripts (ruby/rofi) |
| Super+Shift+M | `/home/wixaxis/scripts/reload_builtin_monitor.rb` | scripts |
| **Media** | | |
| XF86MonBrightness* | `/home/wixaxis/scripts/brightness.rb` | scripts |
| XF86LaunchA | `brightness.rb !` | scripts |
| XF86AudioPlay/Next/Prev | `playerctl play-pause/next/prev` | **playerctl** |
| XF86AudioRaiseVolume/Lower/Mute | `/home/wixaxis/scripts/volume-osd.sh` | scripts → **wob** or fallback |
| **Screenshots** | | |
| Super+P | `flameshot gui` | **flameshot** |
| **base_bindings** | | |
| Super+R (resize) | `hyprctl notify ...` | hyprland built-in |
| escape (in submap) | `hyprctl notify ...` | hyprland built-in |

**Not in `check-installed-packages.sh` or `setup.sh`:** vicinae, cliphist, wl-copy (wl-clipboard), playerctl, thunar (in stow but not in check script), **opencode** (Super+A, tmuxinator windows, `oc` alias in shells, mimeapps handler).

---

## 1. Programs referenced in config but missing (or not in package lists)

### Not installed (confirmed by `check-installed-packages.sh`)

| Program  | Where used | Action |
|----------|-------------|--------|
| *(none remaining)* | Solaar was removed from autostart and package lists; `solaar/` config dir kept in repo. | — |

### Used in config but not in `check-installed-packages.sh` or `setup.sh`

These are executed by Hyprland bindings (see table above), autostart, or waybar but not checked by the repo scripts:

| Program / package | Where used | Note |
|-------------------|------------|------|
| **udiskie** | `autostart.conf` | Auto-mount removable drives. Install if you use USB drives. |
| **wob** | `autostart.conf`, `volume-osd.sh` | Volume/brightness OSD. You have `wob/` config but **wob is not in `stow-platform.sh`** — add it to LINUX_PACKAGES if you want it stowed. |
| **cliphist** | `autostart.conf`, bindings (clipboard history) | Clipboard manager. Install `cliphist` (AUR or your distro). |
| **wl-copy** / **wl-paste** | `autostart.conf`, bindings | From `wl-clipboard`. Usually with Hyprland/Wayland. |
| **playerctl** | `bindings.conf` (media keys) | Media control. Install if you use media keys. |
| **pavucontrol** | `waybar/config.jsonc` (pulseaudio on-click) | Install if you want the waybar volume click to work. |
| **vicinae** | `autostart.conf`, bindings | Launcher; likely AUR or external. Not in dotfiles package lists. |

### Stow vs repo layout

- **wob**: Has `wob/` directory and is used in autostart, but **not listed in `stow-platform.sh`**. Add to `LINUX_PACKAGES` if you want it stowed with the script.
- **flameshot**: Has `flameshot/` directory and is in `setup.sh` arch_packages, but **not in `stow-platform.sh`**. Add to `LINUX_PACKAGES` if you want it stowed there.
- **glow**, **papes**, **thunar**: In `stow-platform.sh` but **not in `check-installed-packages.sh`**. Add to the check script if you want install audits for them.

---

## 2. No longer used (or stale references)

### Replaced / archived but still referenced in config

| Reference | Location | Status |
|-----------|----------|--------|
| **kitty** | `waybar/config.jsonc` | Fixed: on-click now uses `ghostty`. |
| **termite** | `rofi/rofimenu.config` | Fixed: Terminal and Wi-Fi entries now use `ghostty`. |

### Optional / alternate code paths

- **hyprshot**: Removed (scripts deleted). Screenshots use **flameshot** only.

---

## 3. Cleanup done (2025-03-15)

- **solaar**: Removed `exec-once = solaar -w hide` from `autostart.conf`. Removed from `stow-platform.sh` and `check-installed-packages.sh`. Config dir `solaar/` kept in repo for reference if you install later.
- **waybar**: Updated network on-click from `kitty` → `ghostty -e sh -c '...'`.
- **rofi**: Updated `rofimenu.config` Terminal and Wi-Fi entries from `termite` → `ghostty`.
- **hyprshot**: Removed; using flameshot only. Deleted `scripts/scripts/rofi-hyprshot.rb` and `scripts/scripts/dump/rofi-hyprshot.sh`. Updated README and audit.

## 4. Optional next steps

1. **check-installed-packages.sh**: Add `glow`, `papes`, `thunar` (and optionally `wob`, `flameshot`) if you want them in the audit.
2. **stow-platform.sh**: Add `wob` and `flameshot` to `LINUX_PACKAGES` if you want them stowed with the script.
3. **setup.sh**: Consider adding runtime deps used by autostart/bindings: e.g. `udiskie`, `cliphist`, `wl-clipboard`, `playerctl`, `pavucontrol` (and optionally `wob`) for Arch so `check_packages` can report missing ones.
4. **Unstow solaar** if it was stowed: `stow -t ~ -D solaar` from repo root.
