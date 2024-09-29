#!/home/wixaxis/.local/share/rbenv/shims/ruby
# frozen_string_literal: true

require 'json'

DAEMON = 'hyprpaper'
# DAEMON = 'swww'

WALLPAPERS_ROOT = '/home/wixaxis/Pictures/nord-papes/'
DARK_PAPES_ROOT = "#{WALLPAPERS_ROOT}dark/".freeze
LIGHT_PAPES_ROOT = "#{WALLPAPERS_ROOT}light/".freeze
CURR_THEME = `gsettings get org.gnome.desktop.interface color-scheme`.include?('light') ? 'light' : 'dark'

papes_from_dir = ->(dir) { Dir.children(dir).filter_map { |fname| "#{dir}#{fname}" if File.file?(dir + fname) } }
all_papes = lambda { |theme|
  papes_from_dir.call(WALLPAPERS_ROOT) + papes_from_dir.call(theme == 'light' ? LIGHT_PAPES_ROOT : DARK_PAPES_ROOT)
}

swww_flags = '-t random --transition-duration 0.5 --transition-fps 144 --transition-step 255'

use_wallpaper = case DAEMON
                when 'swww'
                  ->(monitor, path) { `swww img -o #{monitor} #{swww_flags} #{path}` }
                when 'hyprpaper'
                  lambda { |monitor, path|
                    `hyprctl hyprpaper preload #{path}`
                    `hyprctl hyprpaper wallpaper #{monitor},#{path}`
                    `hyprctl hyprpaper unload unused`
                  }
                end
# `killall hyprpaper && hyprctl dispatch exec hyprpaper` if DAEMON == 'hyprpaper'
JSON.parse(`wlr-randr --json`).map { |monitor| monitor['name'] }
    .each { |name| use_wallpaper.call(name, all_papes.call(CURR_THEME).sample) }
