local wezterm = require("wezterm")
local utf8 = require("utf8")
local color_assets = require("97-assets").colors

local TERMINAL_ICON_WITH_PADDING = utf8.char(0xE795) -- 

local function has_custom_tab_title(tab)
  local title = tab.tab_title
  return title and title ~= "" and title ~= "default"
end

local function process_or_custom_title(str, tab)
  if has_custom_tab_title(tab) then
    return tab.tab_title
  end

  return str
end

local M = {}

-- [[
-- ------------------------------------ Tabline ---------------------------------------
-- ]]

local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup({
  options = {
    theme = "Catppuccin Macchiato",
    color_overrides = {
      normal_mode = {
        a = { bg = color_assets.fresh_green },
      },
      tab = {
        active = { fg = color_assets.lt_black, bg = color_assets.lt_orange },
        inactive = { fg = color_assets.warm_white },
        inactive_hover = { fg = color_assets.lt_gray, bg = color_assets.nut_gray },
      },
    },
    tab_separators = {
      left = wezterm.nerdfonts.pl_left_hard_divider,
      right = wezterm.nerdfonts.pl_right_hard_divider,
    },
  },
  sections = {
    tabline_a = {
      {
        "mode",
        padding = 1,
        fmt = function()
          return TERMINAL_ICON_WITH_PADDING
        end,
      },
    },
    -- tabline_b = {}, -- workspaces
    tabline_x = {}, --\
    tabline_y = {}, -- batteries and stuff
    tabline_z = {}, --/
    tab_active = {
      "index",
      { "process", fmt = process_or_custom_title },
      "zoomed",
    },
    tab_inactive = {
      "index",
      { "process", fmt = process_or_custom_title },
    }
  },
})

M.tabline = tabline


-- [[
-- ------------------------------------ RESURRECT ---------------------------------------
-- ]]

local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
local resurrect_state_dir = wezterm.home_dir .. "/.local/state/wezterm/resurrect/"

local function notify(msg, timeout_ms)
  if not wezterm.gui then
    return
  end
  local windows = wezterm.gui.gui_windows()
  if windows and windows[1] then
    windows[1]:toast_notification("wezterm", msg, nil, timeout_ms or 2500)
  end
end

resurrect.state_manager.change_state_save_dir(resurrect_state_dir)
resurrect.state_manager.periodic_save({
    interval_seconds = 60,
    save_tabs = true,
    save_windows = true,
    save_workspaces = true,
})

wezterm.on("gui-startup", function()
  local ok, err = pcall(function()
    resurrect.state_manager.resurrect_on_gui_startup()
  end)
  if not ok then
    wezterm.log_error("resurrect gui-startup failed: " .. tostring(err))
    notify("resurrect startup restore failed")
  else
    wezterm.log_info("resurrect gui-startup attempted")
    notify("resurrect startup restore attempted", 1800)
  end
end)

wezterm.on("resurrect.error", function(err)
  wezterm.log_error("resurrect error: " .. tostring(err))
  notify("resurrect error: " .. tostring(err), 5000)
end)

wezterm.on("resurrect.state_manager.save_state.finished", function()
  local ok, err = pcall(function()
    local workspace = wezterm.mux.get_active_workspace()
    resurrect.state_manager.write_current_state(workspace, "workspace")
  end)
  if not ok then
    wezterm.log_error("resurrect write_current_state failed: " .. tostring(err))
  else
    notify("resurrect autosave complete", 1200)
  end
end)

wezterm.on("smart_workspace_switcher.workspace_switcher.selected", function()
  local ok, err = pcall(function()
    local workspace = wezterm.mux.get_active_workspace()
    resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
    resurrect.state_manager.write_current_state(workspace, "workspace")
  end)
  if not ok then
    wezterm.log_error("resurrect save on workspace switch failed: " .. tostring(err))
  end
end)

wezterm.on("smart_workspace_switcher.workspace_switcher.created", function(window, _, label)
  local ok, err = pcall(function()
    local state = resurrect.state_manager.load_state(label, "workspace")
    if state then
      resurrect.workspace_state.restore_workspace(state, {
        window = window,
        relative = true,
        restore_text = true,
        on_pane_restore = resurrect.tab_state.default_on_pane_restore,
      })
    end
  end)
  if not ok then
    wezterm.log_error("resurrect restore on workspace create failed: " .. tostring(err))
  end
end)

-- [[
-- --------------------------------------------------- ---------------------------------------
-- ]]

return M
