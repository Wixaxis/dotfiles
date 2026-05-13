# Hyprland Lua Config — Migration Complete

> **Status:** Migrated to **Lua** (`.lua` files) for Hyprland 0.55+.
> **Previous format:** hyprlang (`.conf` files) — see git history if needed.

## Structure

The config is split into modular Lua files under `~/.config/hypr/lua/`:

```
~/.config/hypr/
├── hyprland.lua          -- Main entrypoint
├── lua/
│   ├── env.lua           -- Environment variables
│   ├── monitors.lua      -- Monitor definitions
│   ├── input.lua         -- Input settings + per-device overrides
│   ├── general.lua       -- General, decoration, cursor, misc
│   ├── layouts.lua       -- Master, dwindle, scrolling
│   ├── animations.lua    -- Curves + animations
│   ├── binds.lua         -- All keybinds
│   ├── window_rules.lua  -- Window rules
│   └── autostart.lua     -- Startup apps + hooks
├── hypridle.conf         -- Unchanged (conf format)
├── hyprlock.conf         -- Unchanged (conf format)
└── hyprpaper.conf        -- Unchanged (conf format)
```

## Key design decisions

- **No external scripts** for Hyprland runtime: device config, monitor detection, and autostart are all native Lua.
- **Bash helpers** only for external hardware control (`brightness.sh`, `randomize_wallpaper.sh`, `volume-osd.sh`).
- **Dead Ruby scripts removed**: `rb-setup-monitors.rb`, `listen_monitors.rb`, `reload_adjust_swaync.rb`, `randomize_wallpaper.rb`, `brightness.rb`, and their helper modules.

## Quick API reference

```lua
-- Monitor
hl.monitor({ output = "DP-1", mode = "1920x1080@144", position = "0x0", scale = 1 })

-- General settings
hl.config({ general = { gaps_in = 5, gaps_out = 20, border_size = 2 } })

-- Environment variables
hl.env("XCURSOR_SIZE", "24")

-- Keybinds
local mainMod = "SUPER"
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + C", hl.dsp.window.close())

-- Window rules
hl.window_rule({ match = { class = "MyTerm" }, float = true })

-- Animations / curves
hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1}, {0.32, 1} } })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, spring = "easy" })

-- Devices
hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })

-- Autostart hook
hl.on("hyprland.start", function()
  hl.exec_cmd("waybar")
end)

-- Device-specific overrides
local hostname = os.getenv("HOSTNAME") or ""
if hostname == "wixaxis-minibook" then
    hl.config({ input = { sensitivity = 0.0 } })
end
```

## Official docs

- **Full Lua reference** (scraped from wiki): `HYPR_LUA_CONFIG_REFERENCE.md` (this directory)
- **Official wiki (latest git):** https://wiki.hypr.land/Configuring/Start/
- **Old hyprlang wiki (0.54):** https://wiki.hypr.land/0.54.0/
- **Example Lua config:** https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.lua

## LSP setup (optional)

Add `.luarc.json` next to your config:

```json
{
  "workspace": {
    "library": ["/usr/share/hypr/stubs"]
  },
  "diagnostics": {
    "globals": ["hl"]
  }
}
```
