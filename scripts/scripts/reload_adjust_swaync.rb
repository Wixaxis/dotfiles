#!/usr/bin/env -S mise exec ruby@latest -- ruby
# frozen_string_literal: true

require '/home/wixaxis/.config/swaync/schema/config_base'
require 'json'

CONFIG_FILE_PATH = '/home/wixaxis/.config/swaync/config.json'

def bluetooth_audio_current?
  false # TODO: Implement checking if current audio output is bluetooth
end

def generated_volume_config
  { 'volume': { "label": bluetooth_audio_current? ? '' : '' } }
end

# TODO: ideally add refresh of ddcci-driver-linux before fetching names

def backlights_available_names
  Dir.children('/sys/class/backlight')
rescue StandardError => e
  `notify-send --urgency=low --icon=dialog-error "Error Reading Backlight Device" "Refreshing notification center backlight devices failed. Error: #{e.message}"`
  ['intel_backlight']
end

def generated_backlights_config
  backlights_available_names.map do |name|
    label = name == 'intel_backlight' ? ' 󰃟' : '󰍹 󰃟'

    { "backlight##{name}": { 'label': label, 'device': name, 'min': 0 } }
  end
end

def write_to_config_file(config, path)
  File.open path, 'w' do |file|
    file.puts config
  end
end

widget_configs = {}
widget_configs.merge!(MENUBAR_CONFIG)
widget_configs.merge!(MPRIS_CONFIG)
widget_configs.merge!(TITLE_CONFIG)
widget_configs.merge!(DND_CONFIG)
widget_configs.merge!(NOTIFICATIONS_CONFIG)
widget_configs.merge!(BUTTONSGRID_CONFIG)
generated_backlights_config.each do |backlight_config|
  widget_configs.merge!(backlight_config)
end
widget_configs.merge!(generated_volume_config)

output_config = GENERAL_CONFIG.merge({ 'widgets': widget_configs.keys,
                                       'widget-config': widget_configs.reject { |key, _| key == :notifications } })

`notify-send "UPDATING SWAYNC" "Updating swaync with new monitors setup"`

write_to_config_file JSON.pretty_generate(output_config), CONFIG_FILE_PATH
`swaync-client -R`
