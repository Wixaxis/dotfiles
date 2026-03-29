#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative 'ruby/ensure_process_up'

DAEMON = 'hyprpaper'
# DAEMON = 'swww'

WALLPAPERS_ROOT = File.join(Dir.home, 'Pictures', 'nord-papes')
DARK_PAPES_ROOT = File.join(WALLPAPERS_ROOT, 'dark')
LIGHT_PAPES_ROOT = File.join(WALLPAPERS_ROOT, 'light')
CURR_THEME = `gsettings get org.gnome.desktop.interface color-scheme`.include?('light') ? 'light' : 'dark'

papes_from_dir = lambda do |dir|
  Dir.children(dir).filter_map do |fname|
    full_path = File.join(dir, fname)
    full_path if File.file?(full_path)
  end
end
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

if ensure_running('hyprpaper', 'hyprctl dispatch exec hyprpaper')
  JSON.parse(`wlr-randr --json`).map { |monitor| monitor['name'] }
      .each { |name| use_wallpaper.call(name, all_papes.call(CURR_THEME).sample) }
end
