# frozen_string_literal: true

POWER_MENU_BUTTONS = {
  ' Reboot': 'systemctl reboot',
  ' Lock': 'hyprlock',
  '󰍃 Logout': 'hyprctl dispatch exit',
  '⏻ Shut down': 'systemctl poweroff'
}.freeze

BOTTOM_BUTTONS = {
  '󰖩': "kitty sh -c 'swaync-client -cp && sleep 0.1 && nmtui'",
  '': "sh -c 'swaync-client -cp && pavucontrol'",
  '󱟧': "notify-send -u critical 'Battery Saver' 'Please implement me!'"
}.freeze

MENUBAR_CONFIG = {
  "menubar#label": {
    "menu#power-buttons": {
      'label': '⏻   Power',
      'position': 'left',
      'actions': POWER_MENU_BUTTONS.map do |label, command|
                   { 'label': label, 'command': command }
                 end
    }
  }
}.freeze

MPRIS_CONFIG = { "mpris": { "image-size": 96, "image-radius": 4 } }.freeze

TITLE_CONFIG = {
  "title": {
    "text": 'Notifications',
    "clear-all-button": true,
    "button-text": 'Clear All'
  }
}.freeze

DND_CONFIG = { "dnd": { "text": 'Do Not Disturb' } }.freeze

NOTIFICATIONS_CONFIG = { 'notifications': {} }.freeze

BUTTONSGRID_CONFIG = {
  "buttons-grid": {
    "actions": BOTTOM_BUTTONS.map do |label, command|
      { 'label': label, 'command': command }
    end
  }
}.freeze

BASE_BACKLIGHT_CONFIG = {
  "backlight#internal": {
    "label": ' 󰃟',
    "device": 'intel_backlight',
    "min": 0
  }
}.freeze

BASE_VOLUME_CONFIG = { "volume": { "label": '' } }.freeze

FALLBACK_WIDGETS_CONFIGS = {
  'widget-config': MENUBAR_CONFIG.merge(MPRIS_CONFIG)
                                 .merge(TITLE_CONFIG)
                                 .merge(DND_CONFIG)
                                 .merge(NOTIFICATIONS_CONFIG)
                                 .merge(BUTTONSGRID_CONFIG)
                                 .merge(BASE_BACKLIGHT_CONFIG)
                                 .merge(BASE_VOLUME_CONFIG)
}.freeze

FALLBACK_WIDGETS = {
  "widgets": FALLBACK_WIDGETS_CONFIGS[:'widget-config'].map { |config| config.first.to_s }
}.freeze

GENERAL_CONFIG = {
  "$schema": '/etc/xdg/swaync/configSchema.json',
  "positionX": 'right',
  "positionY": 'top',
  "control-center-margin-top": 5,
  "control-center-margin-bottom": 5,
  "control-center-margin-right": 5,
  "control-center-margin-left": 0,
  "notification-icon-size": 64,
  "notification-body-image-height": 100,
  "notification-body-image-width": 200,
  "timeout": 10,
  "timeout-low": 5,
  "timeout-critical": 0,
  "fit-to-screen": true,
  "control-center-width": 500,
  "control-center-height": 600,
  "notification-window-width": 500,
  "keyboard-shortcuts": true,
  "image-visibility": 'when-available',
  "transition-time": 200,
  "hide-on-clear": false,
  "hide-on-action": true,
  "script-fail-notify": true,
  "scripts": { "example-script": {
    "exec": "echo 'Do something...'",
    "urgency": 'Normal'
  } },
  "notification-visibility": {
    "example-name": {
      "state": 'muted',
      "urgency": 'Low',
      "app-name": 'Spotify'
    }
  }
}.freeze

FALLBACK_CONFIG = GENERAL_CONFIG.merge(FALLBACK_WIDGETS).merge(FALLBACK_WIDGETS_CONFIGS).freeze
