#!/usr/bin/env -S mise exec ruby@latest -- ruby
# frozen_string_literal: true

require '/home/wixaxis/scripts/ruby/rofi_base'

where_to = ->(save = false) { save ? "-o '/home/wixaxis/Pictures/screenshots/'" : '--clipboard-only' }
shoot = ->(mode = 'region', save = false) { `killall rofi && hyprshot -m #{mode} #{where_to.call save}` }

handle_rofi opts: {
  region: shoot,
  screen: -> { shoot.call 'output' },
  window: -> { shoot.call 'window' },
  'region & save': -> { shoot.call 'region', true },
  'screen & save': -> { shoot.call 'output', true },
  'window & save': -> { shoot.call 'window', true }
}, modename: 'hyprshot', path: '/home/wixaxis/scripts/rofi-hyprshot.rb'
