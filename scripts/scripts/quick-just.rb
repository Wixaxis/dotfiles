#!/home/wixaxis/.local/share/rbenv/shims/ruby
# frozen_string_literal: true

require 'json'
require '/home/wixaxis/scripts/ruby/rofi_base'

opts = {}

JSON.parse(`just -f /home/wixaxis/justfile --dump --dump-format json`)['recipes'].each do |name, options|
  callback = if options['quiet']
               -> { `killall rofi && just -f /home/wixaxis/justfile #{name}` }
             else -> { `killall rofi && kitty --hold -e just -f /home/wixaxis/justfile #{name}` }; end
  opts[name.to_sym] = callback unless name[0] == '_'
end

handle_rofi opts:, modename: 'just', path: '/home/wixaxis/scripts/quick-just.rb'
