# Device-Specific Configuration in Hyprland

## Overview

Since migrating to the Lua configuration format (Hyprland 0.55+), device-specific overrides are handled directly in Lua at config parse time. No external scripts are needed.

## Current Implementation

Device-specific logic lives in two Lua modules under `~/.config/hypr/lua/`:

### `input.lua`

```lua
-- Default sensitivity for all devices
hl.config({
    input = {
        sensitivity = -0.6,
    },
})

-- Device-specific overrides based on hostname
local hostname = os.getenv("HOSTNAME") or ""

if hostname == "wixaxis-minibook" then
    -- Faster cursor speed for minibook
    hl.config({ input = { sensitivity = 0.0 } })
end
```

### `layouts.lua`

```lua
-- Default scrolling column width
hl.config({
    scrolling = {
        column_width = 0.49,
    },
})

-- Device-specific overrides based on hostname
local hostname = os.getenv("HOSTNAME") or ""

if hostname == "wixaxis-minibook" then
    -- Wider windows for minibook (90% width)
    hl.config({ scrolling = { column_width = 0.9 } })
end
```

## How it works

1. `os.getenv("HOSTNAME")` reads the hostname at config parse time
2. Conditional `hl.config()` calls override the defaults for specific machines
3. No external scripts, no `exec` hooks, no `hyprctl keyword` calls needed
4. Overrides apply immediately on config load/reload

## Adding Device-Specific Settings

### Step 1: Determine your hostname

```bash
uname -n
# Example output: wixaxis-minibook
```

### Step 2: Edit the relevant Lua module

Open `~/.config/hypr/lua/input.lua` (or `layouts.lua`, `general.lua`, etc.) and add a conditional block:

```lua
local hostname = os.getenv("HOSTNAME") or ""

if hostname == "your-device-name" then
    hl.config({ input = { sensitivity = 0.5 } })
    hl.config({ general = { gaps_in = 8 } })
end
```

### Step 3: Test the change

```bash
hyprctl reload
# Or restart Hyprland to verify
```

### Step 4: Verify it applied

```bash
hyprctl getoption input:sensitivity
```

## Finding Your Hostname

```bash
uname -n
# or
cat /etc/hostname
```

## References

- [Hyprland Lua Config Reference](HYPR_LUA_CONFIG_REFERENCE.md)
- [Hyprland Wiki — Start Here](https://wiki.hypr.land/Configuring/Start/)
- [Hyprland Wiki — Variables](https://wiki.hypr.land/Configuring/Basics/Variables/)
