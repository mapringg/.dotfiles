local wezterm = require("wezterm")

local module = {}

function module.apply_to_config(config)
  config.color_scheme = "Catppuccin Mocha"
  config.enable_tab_bar = false
  config.font = wezterm.font("MonoLisa")
  config.font_size = 11
  config.line_height = 1.1
  config.bold_brightens_ansi_colors = true
  config.window_close_confirmation = "NeverPrompt"
  config.front_end = "WebGpu"
  config.webgpu_power_preference = "HighPerformance"
  config.cursor_blink_ease_in = "Constant"
  config.cursor_blink_ease_out = "Constant"
  config.underline_thickness = 3
  config.cursor_thickness = 4
  config.underline_position = -6
  config.default_cursor_style = "BlinkingBar"
  config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
  config.scrollback_lines = 10000
end

return module
