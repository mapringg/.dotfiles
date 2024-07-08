local wezterm = require("wezterm")

local module = {}

function module.apply_to_config(config)
  config.font = wezterm.font("MonoLisa")
  config.font_size = 11
  config.window_close_confirmation = "NeverPrompt"
  config.hide_tab_bar_if_only_one_tab = true
end

return module
