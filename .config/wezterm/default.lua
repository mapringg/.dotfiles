local wezterm = require("wezterm")

local module = {}

function module.apply_to_config(config)
	config.color_scheme = "Catppuccin Mocha"
	config.enable_tab_bar = false
	config.font = wezterm.font("MonoLisa")
	config.line_height = 1.1
	config.window_close_confirmation = "NeverPrompt"
end

return module
