local WALLPAPERS_ROOT = os.getenv("HOME") .. "/Pictures/nord-papes"
local DARK_PAPES_ROOT = WALLPAPERS_ROOT .. "/dark"
local LIGHT_PAPES_ROOT = WALLPAPERS_ROOT .. "/light"

local CURR_THEME = function()
  local h = io.popen("gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null")
  local out = h:read("*a") or ""
  h:close()
  return out:find("light") and "light" or "dark"
end

local papes_from_dir = function(dir)
  local h = io.popen("ls -1 " .. dir .. " 2>/dev/null")
  local out = h:read("*a") or ""
  h:close()
  local t = {}
  for fname in out:gmatch("[^\n]+") do
    t[#t+1] = dir .. "/" .. fname
  end
  return t
end

local all_papes = function(theme)
  local t = {}
  for _, p in ipairs(papes_from_dir(WALLPAPERS_ROOT)) do t[#t+1] = p end
  for _, p in ipairs(papes_from_dir(theme == "light" and LIGHT_PAPES_ROOT or DARK_PAPES_ROOT)) do t[#t+1] = p end
  return t
end

local apply = function(monitor, path)
  hl.exec_cmd("hyprctl hyprpaper preload " .. path)
  hl.exec_cmd("hyprctl hyprpaper wallpaper " .. monitor .. "," .. path)
end

local M = {}

M.randomize = function()
  local theme = CURR_THEME()
  local papes = all_papes(theme)
  if #papes == 0 then
    hl.exec_cmd('notify-send "Wallpaper" "No wallpapers found"')
    return
  end

  hl.exec_cmd("hyprpaper")

  local monitors = hl.get_monitors()
  if #monitors == 0 then
    hl.exec_cmd('notify-send "Wallpaper" "No monitors found"')
    return
  end

  for _, m in ipairs(monitors) do
    apply(m.name, papes[math.random(1, #papes)])
  end
end

return M
