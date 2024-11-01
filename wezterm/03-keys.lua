local wezterm = require("wezterm")
local utils = require("utils")

local keys = {
	--[[
  -- --------------------------------- SPLIT PANES ------------------------------------
  --]]
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

	--[[
  -- --------------------------------- NAVIGATION ------------------------------------
  --]]
	{ key = "h", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Left" }) },
	{ key = "j", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Down" }) },
	{ key = "k", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Up" }) },
	{ key = "l", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Right" }) },

	{ key = "H", mods = "CTRL|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Left", 3 } }) },
	{ key = "J", mods = "CTRL|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Down", 2 } }) },
	{ key = "K", mods = "CTRL|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Up", 2 } }) },
	{ key = "L", mods = "CTRL|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Right", 3 } }) },

	-- Open new tab using current panes' PWD (domain)
	{ key = "c", mods = "LEADER|CTRL", action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }) },

	-- Close current pane
	{ key = "c", mods = "LEADER", action = wezterm.action({ CloseCurrentPane = { confirm = true } }) },

	--[[
  -- --------------------------------- COPY ----------------------------------------
  --]]
	{ key = "Space", mods = "CTRL|SHIFT", action = "ActivateCopyMode" },

	--[[
  -- -------------------------------- ZOOM -----------------------------------------
  --]]
	{
		key = "z",
		mods = "LEADER",
		action = wezterm.action.TogglePaneZoomState,
	},

	--[[
  -- ------------------------------ WORKSPACES -------------------------------------
  --]]
	-- list tabs in a workspace
	{ key = "l", mods = "ALT", action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|TABS" }) },

	-- list workspaces
	{
		key = "l",
		mods = "SHIFT|ALT",
		action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }),
	},

	-- kill a whole workspace forcefully
	{
		key = "k",
		mods = "SHIFT|ALT",
		action = wezterm.action_callback(function(window)
			local w = window:active_workspace()
			utils.kill_workspace(w)
		end),
	},

	-- monitoring workspace
	{
		key = "u",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SwitchToWorkspace({
			name = "monitoring",
			spawn = {
				args = { "btop" },
			},
		}),
	},

	-- Prompt for a name to use for a new workspace and switch to it.
	{
		key = "w",
		mods = "CTRL|SHIFT",
		action = wezterm.action.PromptInputLine({
			description = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { AnsiColor = "Fuchsia" } },
				{ Text = "Enter name for new workspace" },
			}),
			action = wezterm.action_callback(function(window, pane, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					window:perform_action(
						wezterm.action.SwitchToWorkspace({
							name = line,
						}),
						pane
					)
				end
			end),
		}),
	},
}

for i = 1, 9 do
	-- leader + number to activate that tab
	table.insert(keys, {
		key = tostring(i),
		mods = "LEADER",
		action = wezterm.action({ ActivateTab = i - 1 }),
	})
end

return {
	keys = keys,
}
