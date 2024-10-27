local wezterm = require("wezterm")

local config = {
	color_scheme = "Catppuccin Macchiato",

	-- with leader we can mimic TMUX
	leader = { key = "f", mods = "CTRL" },
	keys = {
		{
			key = "v",
			mods = "LEADER",
			action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }),
		},
		{
			key = "s",
			mods = "LEADER",
			action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }),
		},
		{ key = "h", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Left" }) },
		{ key = "j", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Down" }) },
		{ key = "k", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Up" }) },
		{ key = "l", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Right" }) },

		{ key = "H", mods = "LEADER", action = wezterm.action({ AdjustPaneSize = { "Left", 2 } }) },
		{ key = "J", mods = "LEADER", action = wezterm.action({ AdjustPaneSize = { "Down", 2 } }) },
		{ key = "K", mods = "LEADER", action = wezterm.action({ AdjustPaneSize = { "Up", 2 } }) },
		{ key = "L", mods = "LEADER", action = wezterm.action({ AdjustPaneSize = { "Right", 2 } }) },

		{ key = "c", mods = "LEADER|CTRL", action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }) },
		{ key = "c", mods = "LEADER", action = wezterm.action({ CloseCurrentPane = { confirm = true } }) },

		-- zoom pane
		{
			key = "z",
			mods = "LEADER",
			action = wezterm.action.TogglePaneZoomState,
		},

		-- Switch tabs with leader + number
		-- not using a for loop to do the below part to keep the context together ¯\_(ツ)_/¯
		{ key = "1", mods = "LEADER", action = wezterm.action({ ActivateTab = 0 }) },
		{ key = "2", mods = "LEADER", action = wezterm.action({ ActivateTab = 1 }) },
		{ key = "3", mods = "LEADER", action = wezterm.action({ ActivateTab = 2 }) },
		{ key = "4", mods = "LEADER", action = wezterm.action({ ActivateTab = 3 }) },
		{ key = "5", mods = "LEADER", action = wezterm.action({ ActivateTab = 4 }) },
		{ key = "6", mods = "LEADER", action = wezterm.action({ ActivateTab = 5 }) },
		{ key = "7", mods = "LEADER", action = wezterm.action({ ActivateTab = 6 }) },
		{ key = "8", mods = "LEADER", action = wezterm.action({ ActivateTab = 7 }) },
		{ key = "9", mods = "LEADER", action = wezterm.action({ ActivateTab = 8 }) },
		{ key = "Space", mods = "CTRL|SHIFT", action = "ActivateCopyMode" },
	},

	wezterm.on("format-tab-title", function(tab)
		local index = tab.tab_index + 1 -- Tab index (starting from 1)
		local title = tab.active_pane.title -- Default title of the active pane
		local zoom_icon = ""

		-- Format the title to include index: title e.g. `1: vi`
		local formatted_title = string.format("%d: %s ", index, title)

		-- Check if the pane is zoomed and add an icon if it is
		if tab.is_active and tab.active_pane.is_zoomed then
			zoom_icon = "()" -- Icon to indicate zoom; change this to any icon or text you like
		end

		return {
			{ Text = zoom_icon .. " " .. formatted_title },
		}
	end),

	-- Font configuration
	-- font_size = 11.0,
	font = wezterm.font_with_fallback({
		{ family = "MesloLGS Nerd Font Mono", weight = "Regular" },
		{ family = "MesloLGS Nerd Font Mono", weight = "Bold" },
		{ family = "MesloLGS Nerd Font Mono", style = "Italic" },
		{ family = "MesloLGS Nerd Font Mono", weight = "Bold", style = "Italic" },
	}),
	harfbuzz_features = { "liga=1", "clig=1", "calt=1" },

	-- Window appearance
	window_background_opacity = 0.98,
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	initial_cols = 120,
	initial_rows = 40,

	-- Cursor configuration
	default_cursor_style = "SteadyBlock",
	cursor_blink_ease_in = "Constant",
	cursor_blink_ease_out = "Constant",
	cursor_blink_rate = 0,
	force_reverse_video_cursor = true,

	-- Environment
	set_environment_variables = {
		TERM = "xterm-256color",
	},

	-- Scrolling
	scrollback_lines = 10000,

	use_fancy_tab_bar = false,
	status_update_interval = 1000,

	tab_and_split_indices_are_zero_based = false,
	hide_tab_bar_if_only_one_tab = false,
	show_new_tab_button_in_tab_bar = false,
	window_close_confirmation = "NeverPrompt",
	window_decorations = "NONE",

	adjust_window_size_when_changing_font_size = true,
	-- tab_max_width = 50,
	-- tmux status
	wezterm.on("update-right-status", function(window, _)
		local ARROW_FOREGROUND = { Foreground = { Color = "#c6a0f6" } }
		local prefix = " " .. utf8.char(0x1F5A5)
		local left_status_color = "#a6e3a1"

		if window:leader_is_active() then
			left_status_color = "#f38ba8"
		end

		if window:active_tab():tab_id() ~= 0 then
			ARROW_FOREGROUND = { Foreground = { Color = "#1e2030" } }
		end -- arrow color based on if tab is first pane

		window:set_left_status(wezterm.format({
			{ Background = { Color = left_status_color } },
			{ Text = prefix },
			ARROW_FOREGROUND,
			{ Text = " " },
		}))
	end),

	-- Colors
	colors = {
		tab_bar = {
			active_tab = { bg_color = "#fab387", fg_color = "#1A1A1A" },
			inactive_tab = { bg_color = "#282C34", fg_color = "#FFFFF9" },
			inactive_tab_hover = { bg_color = "#3B4048", fg_color = "#D0D0D0", italic = true },
		},
	},

	hyperlink_rules = wezterm.default_hyperlink_rules(),
}

table.insert(config.hyperlink_rules, {
	-- JIRA Issues
	regex = [[\b([A-Z]+-\d+)\b]],
	format = "https://jira.stibodx.com/browse/$0",
	highlight = 1,
})

return config
