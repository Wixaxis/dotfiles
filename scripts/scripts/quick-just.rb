#!/home/wixaxis/.local/share/rbenv/shims/ruby
# frozen_string_literal: true

require 'json'
require '/home/wixaxis/scripts/ruby/handle_dmenu'

opts = {}

JSON.parse(`just -f /home/wixaxis/justfile --dump --dump-format json`)['recipes'].each do |name, options|
  callback = if options['quiet']
               lambda {
                 close_dmenu
                 `just -f /home/wixaxis/justfile #{name}`
               }
             else
               lambda {
                 close_dmenu
                 `ghostty -e "nu -c 'just -f /home/wixaxis/justfile #{name}'"`
               }
             end
  opts[name.to_sym] = callback unless name[0] == '_'
end

handle_dmenu opts:, modename: 'just', path: '/home/wixaxis/scripts/quick-just.rb'
