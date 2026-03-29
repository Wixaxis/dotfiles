#!/usr/bin/env -S mise exec ruby -- ruby
# frozen_string_literal: true

require_relative 'ruby/handle_dmenu'

launcher_path = File.join(Dir.home, 'scripts', File.basename(__FILE__))

handle_dmenu opts: {
  suspend: -> { `systemctl suspend` },
  hibernate: -> { `systemctl hibernate` },
  reboot: -> { `systemctl reboot` },
  poweroff: -> { `systemctl poweroff` }
}, modename: 'power', path: launcher_path
