# Window and Layer Rules Reference (Hyprland v0.53.0+)

This document provides a quick reference for creating and fixing window and layer rules in Hyprland v0.53.0 and later. The syntax was completely overhauled in v0.53.0.

## Table of Contents
- [Window Rules](#window-rules)
  - [Syntax](#syntax)
  - [Props (Match Conditions)](#props-match-conditions)
  - [Effects](#effects)
  - [Plugin Effects](#plugin-effects)
  - [Examples](#examples)
- [Layer Rules](#layer-rules)
- [Common Conversions](#common-conversions)

---

## Window Rules

### Syntax

**Named rule syntax:**
```ini
windowrule {
  name = apply-something
  match:class = my-window
  
  border_size = 10
}
```

**Anonymous rule syntax (most common):**
```ini
windowrule = match:class my-window, border_size 10
```

**Key points:**
- Rules are evaluated top to bottom (order matters!)
- All props must match for a rule to be applied
- You can have multiple props and effects per rule
- Only one of each prop type (e.g., can't specify `match:class` twice)
- At least one prop is required

### Props (Match Conditions)

Props use the `match:` prefix and determine which windows get the rule:

| Field | Argument | Description |
|-------|----------|-------------|
| `match:class` | [RegEx] | Windows with `class` matching RegEx |
| `match:title` | [RegEx] | Windows with `title` matching RegEx |
| `match:initial_class` | [RegEx] | Windows with `initialClass` matching RegEx |
| `match:initial_title` | [RegEx] | Windows with `initialTitle` matching RegEx |
| `match:tag` | [name] | Windows with matching `tag` |
| `match:xwayland` | [bool] | Xwayland windows |
| `match:float` | [bool] | Floating windows |
| `match:fullscreen` | [bool] | Fullscreen windows |
| `match:pin` | [bool] | Pinned windows |
| `match:focus` | [bool] | Currently focused window |
| `match:group` | [bool] | Grouped windows |
| `match:modal` | [bool] | Modal windows |
| `match:workspace` | [workspace] | Windows on matching workspace |
| `match:content` | [int] | Content type (0=none, 1=photo, 2=video, 3=game) |
| `match:xdg_tag` | [RegEx] | Match by xdgTag |

**RegEx notes:**
- Uses Google's RE2 (no backreferences, lookahead, etc.)
- To negate: prefix with `negative:`, e.g., `negative:kitty`
- Multiple match conditions are space-separated

### Effects

Effects are comma-separated and applied when props match.

#### Static Effects (evaluated once on window open)

| Effect | Argument | Description |
|--------|----------|-------------|
| `float` | `on` | Floats a window |
| `tile` | `on` | Tiles a window |
| `fullscreen` | `on` | Fullscreens a window |
| `maximize` | `on` | Maximizes a window |
| `move` | `[expr] [expr]` | Moves floating window (monitor-local coordinates) |
| `size` | `[expr] [expr]` | Resizes floating window |
| `center` | `on` | Centers floating window on monitor |
| `pin` | `on` | Pins window (shows on all workspaces, floating only) |
| `monitor` | `[id]` | Sets monitor (id number or name like `DP-1`) |
| `workspace` | `[w]` | Sets workspace (can add `silent` after) |
| `no_initial_focus` | `on` | Disables initial focus |
| `group` | `[options]` | Sets window group properties |

**Expressions:**
- Space-separated (no spaces in math)
- Variables: `monitor_w`, `monitor_h`, `window_x`, `window_y`, `window_w`, `window_h`, `cursor_x`, `cursor_y`
- Example: `move (monitor_w*0.5) (monitor_h*0.5)`

#### Dynamic Effects (re-evaluated when properties change)

| Effect | Argument | Description |
|--------|----------|-------------|
| `border_size` | `[int]` | Sets border size |
| `border_color` | `[c]` | Force border color (see Variables for color format) |
| `opacity` | `[a]` | Additional opacity multiplier (float, or float float, or float float float) |
| `rounding` | `[int]` | Forces rounding (pixels) |
| `no_anim` | `on` | Disables animations |
| `no_blur` | `on` | Disables blur |
| `no_dim` | `on` | Disables window dimming |
| `no_focus` | `on` | Disables focus |
| `no_shadow` | `on` | Disables shadows |
| `stay_focused` | `on` | Forces focus as long as visible |
| `min_size` | `[w] [h]` | Minimum size (int, int) |
| `max_size` | `[w] [h]` | Maximum size (int, int) |
| `tag` | `[name]` | Applies tag (use `+`/`-` prefix to set/unset, or no prefix to toggle) |

### Plugin Effects

**Important:** Plugin effects are handled via the `tag` effect in v0.53.0+.

**Old syntax (v0.52 and earlier):**
```ini
windowrulev2 = plugin:hyprbars:nobar, title:^(Picture-in-Picture)$
```

**New syntax (v0.53.0+):**
```ini
windowrule = match:title ^(Picture-in-Picture)$, tag -hyprbars:nobar
```

**Format:** `tag -plugin:name:effect`
- Use `-` prefix to unset/disable plugin effect
- Use `+` prefix to set/enable plugin effect
- No prefix toggles the effect

### Examples

**Basic floating window:**
```ini
windowrule = match:title ^(Settings)$, float on
```

**Multiple conditions:**
```ini
windowrule = match:title ^(Extension:.*Bitwarden.*)$ match:class ^(zen-alpha)$, float on
```

**Picture-in-Picture with multiple effects:**
```ini
windowrule = match:title ^(Picture-in-Picture)$, float on
windowrule = match:title ^(Picture-in-Picture)$, pin on
windowrule = match:title ^(Picture-in-Picture)$, size 320 180
windowrule = match:title ^(Picture-in-Picture)$, move 100%-325 100%-185
windowrule = match:title ^(Picture-in-Picture)$, no_initial_focus on
windowrule = match:title ^(Picture-in-Picture)$, tag -hyprbars:nobar
```

**Dynamic effects:**
```ini
windowrule = match:class ^(steam)$, stay_focused on
windowrule = match:class ^(steam)$, min_size 1 1
```

**Named rule example:**
```ini
windowrule {
  name = float-bitwarden
  match:title = ^(Extension:.*Bitwarden.*)$
  match:class = ^(zen-alpha)$
  
  float = on
}
```

---

## Layer Rules

Layer rules use a simpler syntax:

```ini
layerrule = blur, waybar
layerrule = ignorealpha 0, vicinae
```

**Common layer rule effects:**
- `blur` - Apply blur
- `ignorealpha` - Ignore alpha channel
- `noanim` - **Note:** Not a valid layer rule option (this was attempted but doesn't work)

**Syntax:**
```ini
layerrule = <effect> [value], <namespace>
```

Where `<namespace>` is the layer shell namespace (e.g., `waybar`, `wob`, `swaync`).

---

## Common Conversions

### From v0.52 to v0.53.0+

| Old (v0.52) | New (v0.53.0+) |
|-------------|----------------|
| `windowrulev2 = float, title:^(Window)$` | `windowrule = match:title ^(Window)$, float on` |
| `windowrulev2 = tile, title:(Neovide)` | `windowrule = match:title (Neovide), tile on` |
| `windowrulev2 = stayfocused, class:^(steam)$` | `windowrule = match:class ^(steam)$, stay_focused on` |
| `windowrulev2 = minsize 1 1, class:^(steam)$` | `windowrule = match:class ^(steam)$, min_size 1 1` |
| `windowrulev2 = noinitialfocus, title:^(PiP)$` | `windowrule = match:title ^(PiP)$, no_initial_focus on` |
| `windowrulev2 = plugin:hyprbars:nobar, title:^(PiP)$` | `windowrule = match:title ^(PiP)$, tag -hyprbars:nobar` |

### Key Changes

1. **Command:** `windowrulev2` → `windowrule`
2. **Match conditions:** `title:regex` → `match:title regex`
3. **Multiple conditions:** Comma-separated → Space-separated
4. **Boolean effects:** Implicit → Explicit `on` (e.g., `float` → `float on`)
5. **Plugin effects:** `plugin:name:effect` → `tag -name:effect`
6. **Naming:** `stayfocused` → `stay_focused`, `noinitialfocus` → `no_initial_focus`, `minsize` → `min_size`

### Conversion Tool

There's an unofficial in-browser converter available at:
https://itsohen.github.io/hyprrulefix/

---

## Troubleshooting

### Common Errors

**Error: `invalid field type plugin:hyprbars:nobar`**
- **Solution:** Use `tag -hyprbars:nobar` instead

**Error: `invalid field type`**
- **Solution:** Check spelling - many effects use underscores (e.g., `stay_focused`, not `stayfocused`)

**Rule not applying:**
- Check rule order (rules are evaluated top to bottom)
- Verify all match conditions are correct (use `hyprctl clients` to check window properties)
- Ensure at least one prop matches

### Checking Window Properties

```bash
hyprctl clients
```

This shows all windows with their `class`, `title`, `initialClass`, `initialTitle`, etc.

### Testing Rules

```bash
# Add rule dynamically
hyprctl keyword windowrule "match:title ^(Test)$, float on"

# Check for errors
hyprctl configerrors

# Reload config
hyprctl reload
```

---

## References

- Official Wiki: https://wiki.hypr.land/Configuring/Window-Rules/
- Official Wiki (Layer Rules): https://wiki.hypr.land/Configuring/Layer-Rules/
- Rule Converter: https://itsohen.github.io/hyprrulefix/
- Hyprland v0.53.0 Release: https://github.com/hyprwm/Hyprland/releases/tag/v0.53.0

---

**Last Updated:** Based on Hyprland v0.53.1
**Note:** This syntax applies to v0.53.0 and later. Older versions use `windowrulev2` syntax.
