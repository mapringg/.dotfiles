local wezterm_action = require("wezterm").action
local module = {}

module.multiple_actions = function(keys)
  local actions = {}
  for key in keys:gmatch(".") do
    table.insert(actions, wezterm_action.SendKey({ key = key }))
  end
  table.insert(actions, wezterm_action.SendKey({ key = "\n" }))
  return wezterm_action.Multiple(actions)
end

module.key_table = function(mods, key, action)
  return {
    mods = mods,
    key = key,
    action = action,
  }
end

module.cmd_key = function(key, action)
  return module.key_table("CMD", key, action)
end

module.cmd_to_tmux_prefix = function(key, tmux_key)
  return module.cmd_key(
    key,
    wezterm_action.Multiple({
      wezterm_action.SendKey({ mods = "CTRL", key = "b" }),
      wezterm_action.SendKey({ key = tmux_key }),
    })
  )
end

return module
