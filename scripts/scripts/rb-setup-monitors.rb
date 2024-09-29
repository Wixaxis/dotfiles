#!/home/wixaxis/.local/share/rbenv/shims/ruby
# frozen_string_literal: true

require 'json'

def set_monitor(setup)
  name = setup[:name]
  position = setup[:position]
  scale = setup[:scale]
  mode = "#{setup[:width]}x#{setup[:height]}@#{setup[:refresh].floor}"
  transform = setup[:transform] ? ",transform,#{setup[:transform]}" : ''
  `hyprctl keyword monitor #{name},#{mode},#{position},#{scale}#{transform}`
  `notify-send 'Monitor #{name} set with #{mode}#{" transform #{setup[:transform]}" if setup[:transform]}'`
end

def best_mode(monitor)
  monitor['modes'].map do |mode|
    { width: mode['width'], height: mode['height'], refresh: mode['refresh'] }
  end.min { |m1, m2| m2.values.inject(:*) - m1.values.inject(:*) }
end

def best_scale(monitor, mode)
  case mode[:height].to_f / monitor['physical_size']['height']
  when 9.. then 1.5
  when 6...9 then 1.25
  else 1; end
end

monitors = JSON.parse `wlr-randr --json`
monitors.each do |monitor|
  mode = best_mode monitor
  set_monitor({
                name: monitor['name'],
                position: monitor[:name] == 'DSI-1' && monitors.count > 1 ? '0x480' : 'auto',
                scale: best_scale(monitor, mode),
                width: mode[:width],
                height: mode[:height],
                refresh: mode[:refresh],
                transform: monitor['name'] == 'DSI-1' ? 3 : nil
              })
end
