#!/home/wixaxis/.local/share/rbenv/shims/ruby
# frozen_string_literal: true

require '/home/wixaxis/scripts/ruby/handle_dmenu.rb'

handle_dmenu opts: {
  suspend: -> { `systemctl suspend` },
  hibernate: -> { `systemctl hibernate` },
  reboot: -> { `systemctl reboot` },
  poweroff: -> { `systemctl poweroff` }
}, modename: 'power', path: '/home/wixaxis/scripts/powermenu.rb'
