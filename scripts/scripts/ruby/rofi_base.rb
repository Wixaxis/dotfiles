#!/usr/bin/env -S mise exec ruby@latest -- ruby
# frozen_string_literal: true

def handle_rofi(opts:, modename: 'script', path: "/home/wixaxis/scripts/#{modename}.rb")
  opts[:init] = -> { `rofi -show #{modename} -modes "#{modename}:#{path}"` }
  opts[:cancel] = -> { `killall rofi` }
  # `notify-send 'run with argument #{ARGV.first&.to_sym} from list '`
  if opts.keys.include? ARGV.first&.to_sym then opts[ARGV.first.to_sym].call
  else
    opts.each_key { |key| puts key if key != :init }; end
end
