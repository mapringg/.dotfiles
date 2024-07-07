local wezterm_action = require("wezterm").action
local keys = require("keys")

local module = {}

function module.apply_to_config(config)
	config.keys = {
		keys.cmd_to_tmux_prefix("1", "1"),
		keys.cmd_to_tmux_prefix("2", "2"),
		keys.cmd_to_tmux_prefix("3", "3"),
		keys.cmd_to_tmux_prefix("4", "4"),
		keys.cmd_to_tmux_prefix("5", "5"),
		keys.cmd_to_tmux_prefix("6", "6"),
		keys.cmd_to_tmux_prefix("7", "7"),
		keys.cmd_to_tmux_prefix("8", "8"),
		keys.cmd_to_tmux_prefix("9", "9"),
		keys.cmd_to_tmux_prefix("t", "c"),
		keys.cmd_to_tmux_prefix("T", "!"),
		keys.cmd_to_tmux_prefix("w", "x"),
		keys.cmd_to_tmux_prefix("k", "k"),
		keys.cmd_to_tmux_prefix("-", '"'),
		keys.cmd_to_tmux_prefix("d", "d"),
		keys.cmd_to_tmux_prefix("z", "z"),
		{
			mods = "CMD|SHIFT",
			key = "|",
			action = wezterm_action.Multiple({
				wezterm_action.SendKey({ mods = "CTRL", key = "b" }),
				wezterm_action.SendKey({ key = "%" }),
			}),
		},
		{
			mods = "CMD|SHIFT",
			key = "}",
			action = wezterm_action.Multiple({
				wezterm_action.SendKey({ mods = "CTRL", key = "b" }),
				wezterm_action.SendKey({ key = "n" }),
			}),
		},
		{
			mods = "CMD|SHIFT",
			key = "{",
			action = wezterm_action.Multiple({
				wezterm_action.SendKey({ mods = "CTRL", key = "b" }),
				wezterm_action.SendKey({ key = "p" }),
			}),
		},
	}
end

return module
