#!/home/wixaxis/.local/share/rbenv/shims/ruby
# frozen_string_literal: true

BACKEND = :vicinae
# BACKEND = :rofi

def handle_dmenu(opts:, modename: 'script', path: "/home/wixaxis/scripts/#{modename}.rb")
  case BACKEND
  when :rofi    then handle_rofi(opts:, modename:, path:)
  when :vicinae then handle_vicinae(opts:, modename:, path:)
  end
end

def close_dmenu
  case BACKEND
  when :rofi    then `killall rofi`
  when :vicinae then `vicinae close`
  end
end

def handle_vicinae(opts:, modename: 'script', path: "/home/wixaxis/scripts/#{modename}.rb")
  opts[:init] = -> { `#{path} $(#{path} | vicinae dmenu --no-section -p "#{modename}")` }
  opts[:cancel] = -> { close_dmenu }
  # `notify-send 'run with argument #{ARGV.first&.to_sym} from list '`
  if opts.keys.include? ARGV.first&.to_sym then opts[ARGV.first.to_sym].call
  else
    opts.each_key { |key| puts key if key != :init }
  end
end

def handle_rofi(opts:, modename: 'script', path: "/home/wixaxis/scripts/#{modename}.rb")
  opts[:init] = -> { `rofi -show #{modename} -modes "#{modename}:#{path}"` }
  opts[:cancel] = -> { close_dmenu }
  # `notify-send 'run with argument #{ARGV.first&.to_sym} from list '`
  if opts.keys.include? ARGV.first&.to_sym then opts[ARGV.first.to_sym].call
  else
    opts.each_key { |key| puts key if key != :init }
  end
end
