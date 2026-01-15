#!/usr/bin/env -S mise exec ruby@latest -- ruby
# frozen_string_literal: true

# MissingOptionError
class MissingOptionError < StandardError
  def initialize(name, option)
    super("Required field #{option} for #{name}")
  end
end

require 'json'
require '/home/wixaxis/scripts/ruby/handle_dmenu.rb'

THEMES_CONFIGS_PATH = '/home/wixaxis/scripts/ruby/theme_configs/'
GRADIENCE_CLI = 'flatpak run --command=gradience-cli com.github.GradienceTeam.Gradience'

def set_with_opts(name, opts)
  case name
  when 'gradience'
    raise MissingOptionError.new(name, 'themeName') unless opts['themeName']

    `#{GRADIENCE_CLI} apply -n '#{opts['themeName']}' --gtk both`
  when 'kitty'
    raise MissingOptionError.new(name, 'themeName') unless opts['themeName']

    `kitten themes --reload-in all #{opts['themeName']}`
  when 'waybar'
    raise MissingOptionError.new(name, 'themeName') unless opts['themeName']
    raise MissingOptionError.new(name, 'colorscheme') unless opts['colorscheme']

    waybar_themes_root = "#{Dir.home}/.config/waybar/themes"
    curr_colorscheme = "@import url(\"#{opts['themeName']}/#{opts['colorscheme']}.css\");"
    curr_theme = "@import url(\"#{opts['themeName']}/theme.css\");"
    File.write "#{waybar_themes_root}/current-colorscheme.css", curr_colorscheme
    File.write "#{waybar_themes_root}/current-theme.css", curr_theme
    `killall waybar && hyprctl dispatch exec waybar`
  when 'rofi'
    raise MissingOptionError.new(name, 'themeName') unless opts['themeName']

    rofi_config = "#{Dir.home}/.config/rofi/config.rasi"
    rofi_theme = "#{Dir.home}/.local/share/rofi/themes/#{opts['themeName']}.rasi"

    File.write rofi_config, "@theme \"#{rofi_theme}\""
  end
end

def apply_config(config)
  if %w[prefer-dark prefer-light default].include? config['colorScheme']
    `gsettings set org.gnome.desktop.interface color-scheme #{config['colorScheme']}`
  end

  config['steps']&.each do |name, opts|
    if opts['cmd'] then exec opts['cmd']
    else
      set_with_opts name, opts
    end
  end
  `notify-send --urgency=low --icon=dialog-information "#{config['name']} theme set"`
end

def parse_config(full_path)
  config = JSON.parse File.read full_path
  { config['name'].to_sym => -> { apply_config config } }
end

def configs_from_path(path = THEMES_CONFIGS_PATH)
  Dir.children(path).map { |filename| path + filename }
     .map { |full_path| File.directory?(full_path) ? configs_from_path(full_path) : parse_config(full_path) }
     .reduce({}) { |all, new| all.merge! new }
end

handle_dmenu opts: configs_from_path, modename: 'themes', path: '/home/wixaxis/scripts/theme_switcher.rb'
