local wezterm = require('wezterm')
local config = wezterm.config_builder()
local act = wezterm.action

-- General
config.enable_wayland = true
config.automatically_reload_config = true

-- Bell
config.audible_bell = "Disabled"

-- Colors
config.bold_brightens_ansi_colors = true

-- Cursor
config.cursor_blink_rate = 0 -- Converted from "Off"

-- Font configuration
config.font_size = 12
config.font = wezterm.font_with_fallback({
  {
    family = "MonoLisa Nerd Font",
    weight = "Medium",
  },
})

-- Mouse
config.hide_mouse_cursor_when_typing = true

-- Window
config.window_decorations = "TITLE | RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.window_padding = {
  left = 4,
  right = 4,
  top = 4,
  bottom = 4,
}

-- Term
config.term = "xterm-256color"

-- MacOS specific
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

-- Key bindings (converted from tmux)
config.leader = { key = 'Space', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
  -- Pane navigation (similar to tmux hjkl)
  {
    key = 'h',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Left',
  },
  {
    key = 'j',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Down',
  },
  {
    key = 'k',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Up',
  },
  {
    key = 'l',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Right',
  },
  
  -- Alt + Arrow keys for pane navigation (without leader)
  {
    key = 'LeftArrow',
    mods = 'ALT',
    action = act.ActivatePaneDirection 'Left',
  },
  {
    key = 'RightArrow',
    mods = 'ALT',
    action = act.ActivatePaneDirection 'Right',
  },
  {
    key = 'UpArrow',
    mods = 'ALT',
    action = act.ActivatePaneDirection 'Up',
  },
  {
    key = 'DownArrow',
    mods = 'ALT',
    action = act.ActivatePaneDirection 'Down',
  },

  -- Window navigation (Shift + Arrow keys)
  {
    key = 'LeftArrow',
    mods = 'SHIFT',
    action = act.ActivateTabRelative(-1),
  },
  {
    key = 'RightArrow',
    mods = 'SHIFT',
    action = act.ActivateTabRelative(1),
  },

  -- Alt + H/L for window navigation
  {
    key = 'h',
    mods = 'ALT',
    action = act.ActivateTabRelative(-1),
  },
  {
    key = 'l',
    mods = 'ALT',
    action = act.ActivateTabRelative(1),
  },

  -- Split panes
  {
    key = '"',
    mods = 'LEADER',
    action = act.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = '%',  -- % key without shift
    mods = 'LEADER',
    action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },

  -- New tab (window in tmux terms)
  {
    key = 'c',
    mods = 'LEADER',
    action = act.SpawnTab 'CurrentPaneDomain',
  },
}

return config
