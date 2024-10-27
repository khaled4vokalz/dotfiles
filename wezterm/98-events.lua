local wezterm = require("wezterm")
local utf8 = require("utf8")
local color_assets = require("97-assets").colors

-- tmux status
wezterm.on("update-right-status", function(window, _)
	local left_status_color = color_assets.fresh_green
	local icon = " " .. utf8.char(0xE795) .. " " -- 

	if window:leader_is_active() then
		left_status_color = color_assets.vibrant_rose
	end

	window:set_left_status(wezterm.format({
		{ Background = { Color = left_status_color } },
		{ Foreground = { Color = color_assets.black } },
		{ Text = icon },
	}))
end)

-- tab title mod to have zoom icon
wezterm.on("format-tab-title", function(tab)
	local index = tab.tab_index + 1 -- Tab index (starting from 1)
	local title = tab.active_pane.title -- Default title of the active pane
	local zoom_icon = ""

	-- Check if the pane is zoomed and add an icon if it is
	if tab.is_active and tab.active_pane.is_zoomed then
		zoom_icon = "() " -- Icon to indicate zoom; change this to any icon or text you like
	end

	-- Format the title to include index: title e.g. `1: vi`
	local formatted_title = string.format(" %s%d: %s ", zoom_icon, index, title)

	return {
		{ Text = formatted_title },
	}
end)
