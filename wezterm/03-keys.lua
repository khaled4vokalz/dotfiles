local wezterm = require("wezterm")
local utils = require("utils")
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")

-- Configure smart_workspace_switcher with cross-platform zoxide path
workspace_switcher.zoxide_path = utils.find_binary("zoxide")

local keys = {
	--[[
  -- --------------------------------- Add New Line (ClaudeCode?)----------------------
  --]]
  {
    key="Enter",
    mods="SHIFT",
    action = wezterm.action({ SendString="\x1b\r" })
  },
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
  -- -------------------------------- TAB ORDER -----------------------------------------
  --]]
	{
		key = "[",
		mods = "CTRL|SHIFT",
		action = wezterm.action.MoveTabRelative(-1), -- left
	},
	{
		key = "]",
		mods = "CTRL|SHIFT",
		action = wezterm.action.MoveTabRelative(1), -- right
	},

	--[[
  -- ------------------------------ WORKSPACES -------------------------------------
  --]]
	-- list tabs in a workspace
	{ key = "l", mods = "ALT", action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|TABS" }) },

	-- list workspaces
	{
		key = "L",
		mods = "LEADER",
		action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }),
	},

	-- kill a whole workspace forcefully
	{
		key = "k",
		mods = "LEADER",
		action = wezterm.action_callback(function(window)
			local w = window:active_workspace()
			utils.kill_workspace(w)
		end),
	},

	-- monitoring workspace
	{
		key = "t",
		mods = "LEADER",
		action = wezterm.action.SwitchToWorkspace({
			name = "monitoring",
			spawn = {
				args = { "btop" },
			},
		}),
	},

  -- Select workspace
  {
    key = 'w',
    mods = 'LEADER',
    action = wezterm.action.ShowLauncherArgs {
      flags = 'FUZZY|WORKSPACES',
    },
  },
  { key = "[", mods = "LEADER", action = wezterm.action.SwitchWorkspaceRelative(1) },
  { key = "]", mods = "LEADER", action = wezterm.action.SwitchWorkspaceRelative(-1) },

  -- Smart workspace switcher
  {
    key = "n",
    mods = "LEADER",
    action = workspace_switcher.switch_workspace(),
  },
  {
    key = "p",
    mods = "LEADER",
    action = workspace_switcher.switch_to_prev_workspace(),
  },

  -- Fuzzy switcher
  -- { key = "f", mods = "LEADER", action = wezterm.action_callback(utils.toggle) },
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
