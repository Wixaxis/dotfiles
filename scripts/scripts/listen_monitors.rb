#!/home/wixaxis/.local/share/rbenv/shims/ruby
# frozen_string_literal: true

def ddc_monitor_buses
  `ddcutil --brief detect`.split.select { |s| s.include? '/dev/i2c-' }.uniq.map { |s| s.split('/').last }
end

def on_monitor_added
  buses = ddc_monitor_buses
  return unless buses.any?

  batch_command = buses.map do |i2c_bus|
    "{ echo 'ddcci 0x37' | sudo tee /sys/bus/i2c/devices/#{i2c_bus}/new_device; }"
  end.join(' && ')
  `pkexec sh -c "#{batch_command}"`
  `notify-send 'script - monitors' 'Monitor with DDCI added, reloading swaync...'`
  `swaync-client -R`
end

def on_monitor_removed
  `notify-send 'script - monitors' 'Monitor removed, reloading swaync...'`
  `swaync-client -R`
end

def handle(line)
  case line
  when /monitoradded.*/, /monitoraddedv2.*/ then p(line) && on_monitor_added
  when /monitorremoved.*/ then p(line) && on_monitor_removed
  end
end

on_monitor_added

popen_cmd = ['socat', '-U', '-', "UNIX-CONNECT:/tmp/hypr/#{ENV['HYPRLAND_INSTANCE_SIGNATURE']}/.socket2.sock"]
IO.popen(popen_cmd, 'r') do |io|
  io.each_line do |line|
    handle line.chomp
  end
end
