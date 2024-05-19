-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.font = wezterm.font_with_fallback {
  'MonoLisa',
  'Symbols Nerd Font'
}
config.tab_bar_at_bottom = true
config.window_close_confirmation = 'NeverPrompt'

-- For example, changing the color scheme:
config.color_scheme = 'Snazzy'

-- and finally, return the configuration to wezterm
return config
