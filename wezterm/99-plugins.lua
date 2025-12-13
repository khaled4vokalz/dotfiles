local wezterm = require("wezterm")
local utf8 = require("utf8")
local color_assets = require("97-assets").colors

local TERMINAL_ICON_WITH_PADDING = utf8.char(0xE795) -- 
local M = {}

-- [[
-- ------------------------------------ Tabline ---------------------------------------
-- ]]

local tabline = wezterm.plugin.require("https://github.com/khaled4vokalz/tabline.wez")
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
  },
})

M.tabline = tabline


-- [[
-- ------------------------------------ RESURRECT ---------------------------------------
-- ]]

local resurrect = wezterm.plugin.require("https://github.com/khaled4vokalz/resurrect.wezterm")
resurrect.state_manager.periodic_save({
    interval_seconds = 300,
    save_tabs = true,
    save_windows = true,
    save_workspaces = true,
})
wezterm.on("gui-startup", resurrect.state_manager.resurrect_on_gui_startup)

-- [[
-- --------------------------------------------------- ---------------------------------------
-- ]]

return M
