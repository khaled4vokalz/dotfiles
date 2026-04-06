local wezterm = require("wezterm")
local utils = require("utils")
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

-- Configure smart_workspace_switcher with cross-platform zoxide path
workspace_switcher.zoxide_path = utils.find_binary("zoxide")

local keys = {
  {
    key = 'E',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.PromptInputLine {
      description = 'Enter new name for tab',
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },

  {
    key = "S",
    mods = "CTRL|SHIFT",
    action = wezterm.action_callback(function(window)
      local ok, err = pcall(function()
        local workspace = wezterm.mux.get_active_workspace()
        resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
        resurrect.state_manager.write_current_state(workspace, "workspace")
      end)
      if not ok then
        wezterm.log_error("resurrect manual save failed: " .. tostring(err))
        window:toast_notification("wezterm", "resurrect save failed", nil, 3000)
      else
        window:toast_notification("wezterm", "resurrect saved workspace", nil, 1500)
      end
    end),
  },

  {
    key = "R",
    mods = "CTRL|SHIFT",
    action = wezterm.action_callback(function(window, pane)
      local ok, err = pcall(function()
        resurrect.fuzzy_loader.fuzzy_load(window, pane, function(id)
          local kind = string.match(id, "^([^/]+)")
          local name = string.match(id, "([^/]+)$")
          name = name and string.match(name, "(.+)%..+$") or nil
          if not kind or not name then
            return
          end

          local opts = {
            relative = true,
            restore_text = true,
            on_pane_restore = resurrect.tab_state.default_on_pane_restore,
          }

          if kind == "workspace" then
            local state = resurrect.state_manager.load_state(name, "workspace")
            if state then
              resurrect.workspace_state.restore_workspace(state, opts)
            end
          elseif kind == "window" then
            local state = resurrect.state_manager.load_state(name, "window")
            if state then
              resurrect.window_state.restore_window(pane:window(), state, opts)
            end
          elseif kind == "tab" then
            local state = resurrect.state_manager.load_state(name, "tab")
            if state then
              resurrect.tab_state.restore_tab(pane:tab(), state, opts)
            end
          end
        end)
      end)
      if not ok then
        wezterm.log_error("resurrect manual restore failed: " .. tostring(err))
        window:toast_notification("wezterm", "resurrect restore failed", nil, 3000)
      end
    end),
  },

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


	-- kill a whole workspace forcefully
	{
		key = "K",
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
	-- Select workspaces
	{
		key = "L",
		mods = "LEADER",
		action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }),
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
