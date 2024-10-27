require("98-events")

-- keep it sorted on require
local colors = require("01-colors")
local fonts = require("02-fonts")
local keymaps = require("03-keys")
local decorations = require("04-window")
local hyperlink_rules = require("05-hyperlinks")
local tabs = require("06-tabs")

local overrides = {
	colors,
	fonts,
	keymaps,
	decorations,
	hyperlink_rules,
	tabs,
}

local config = {
	color_scheme = "Catppuccin Macchiato",

	-- Environment
	set_environment_variables = {
		TERM = "xterm-256color",
	},

	-- with leader we can mimic TMUX
	leader = { key = "f", mods = "CTRL" },

	-- Scrolling (add a bit more to have more context during DEBUG)
	scrollback_lines = 10000,
	harfbuzz_features = { "liga=1", "clig=1", "calt=1" },

	-- Cursor configuration
	default_cursor_style = "SteadyBlock",
	cursor_blink_ease_in = "Constant",
	cursor_blink_ease_out = "Constant",
	cursor_blink_rate = 0,
	force_reverse_video_cursor = true,
}

-- apply config overrides
for _, override_item in pairs(overrides) do
	for key, value in pairs(override_item) do
		config[key] = value
	end
end

return config
