-- Keybindings

local mainMod = "SUPER"

-- ──────────────────────────────────────────────────────────────
--  Focus
-- ──────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- ──────────────────────────────────────────────────────────────
--  Move Windows
-- ──────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- ──────────────────────────────────────────────────────────────
--  Resize submap
-- ──────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
    hl.bind("right", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
    hl.bind("left",  hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
    hl.bind("up",    hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
    hl.bind("down",  hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- ──────────────────────────────────────────────────────────────
--  Layout
-- ──────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + m", hl.dsp.layout("swapwithmaster"))

-- ──────────────────────────────────────────────────────────────
--  Workspaces
-- ──────────────────────────────────────────────────────────────

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
-- TAB is overridden below in Applications section for window switching

-- ──────────────────────────────────────────────────────────────
--  Mouse binds
-- ──────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ──────────────────────────────────────────────────────────────
--  Applications
-- ──────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + RETURN",       hl.dsp.exec_cmd("vicinae app launch com.mitchellh.ghostty.desktop"))
hl.bind(mainMod .. " + G",            hl.dsp.exec_cmd("vicinae app launch com.mitchellh.ghostty.desktop"))
hl.bind(mainMod .. " + SHIFT + RETURN", hl.dsp.exec_cmd("vicinae app launch com.mitchellh.ghostty.desktop --new"))
hl.bind(mainMod .. " + SHIFT + G",    hl.dsp.exec_cmd("vicinae app launch com.mitchellh.ghostty.desktop --new"))
hl.bind(mainMod .. " + W",            hl.dsp.exec_cmd("vicinae app launch google-chrome.desktop"))
hl.bind(mainMod .. " + SHIFT + W",    hl.dsp.exec_cmd("vicinae app launch google-chrome.desktop --new"))
hl.bind(mainMod .. " + T",            hl.dsp.exec_cmd("vicinae app launch org.telegram.desktop.desktop"))
hl.bind(mainMod .. " + SHIFT + T",    hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + A",            hl.dsp.exec_cmd("vicinae app launch opencode-desktop-electron.desktop"))
hl.bind(mainMod .. " + SHIFT + A",    hl.dsp.exec_cmd("vicinae app launch opencode-desktop-electron.desktop --new"))
hl.bind(mainMod .. " + O",            hl.dsp.exec_cmd("vicinae app launch thunar.desktop"))
hl.bind(mainMod .. " + SHIFT + O",    hl.dsp.exec_cmd("vicinae app launch thunar.desktop --new"))
hl.bind(mainMod .. " + B",            hl.dsp.exec_cmd("vicinae app launch md.obsidian.Obsidian.desktop"))
hl.bind(mainMod .. " + SHIFT + B",    hl.dsp.exec_cmd("vicinae app launch md.obsidian.Obsidian.desktop --new"))
hl.bind(mainMod .. " + Space",        hl.dsp.exec_cmd("vicinae toggle"))
hl.bind(mainMod .. " + ALT + Space",  hl.dsp.exec_cmd("vicinae vicinae://extensions/vicinae/core/search-emojis"))
hl.bind(mainMod .. " + TAB",          hl.dsp.exec_cmd("vicinae vicinae://extensions/vicinae/wm/switch-windows"))
hl.bind(mainMod .. " + slash",        hl.dsp.exec_cmd("vicinae vicinae://extensions/sovereign/hypr-keybinds/hyprland-keybinds"))
hl.bind(mainMod .. " + V",            hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + J",            hl.dsp.exec_cmd("/home/wixaxis/scripts/quick-just.rb init"))

-- ──────────────────────────────────────────────────────────────
--  System
-- ──────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + Q",            hl.dsp.window.close())
hl.bind(mainMod .. " + F",            hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F",    hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mainMod .. " + L",            hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + N",            hl.dsp.exec_cmd("swaync-client -t"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + SHIFT + E",    hl.dsp.exec_cmd("/home/wixaxis/scripts/powermenu.rb init"))
hl.bind(mainMod .. " + SHIFT + M",    hl.dsp.exec_cmd("hyprctl keyword monitor DSI-1,disable && hyprctl keyword monitor DSI-1,1200x1920@50,0x480,1.25,transform,3"))

-- ──────────────────────────────────────────────────────────────
--  Media
-- ──────────────────────────────────────────────────────────────

hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("/home/wixaxis/scripts/brightness.sh - 10"), { repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("/home/wixaxis/scripts/brightness.sh + 10"), { repeating = true })
hl.bind("XF86LaunchA",           hl.dsp.exec_cmd("/home/wixaxis/scripts/brightness.sh !"))
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl prev"))
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("/home/wixaxis/scripts/volume-osd.sh up"),   { repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("/home/wixaxis/scripts/volume-osd.sh down"), { repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("/home/wixaxis/scripts/volume-osd.sh toggle"))

-- ──────────────────────────────────────────────────────────────
--  Screenshots
-- ──────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("flameshot gui"))
