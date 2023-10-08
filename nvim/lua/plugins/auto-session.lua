---@diagnostic disable: assign-type-mismatch, missing-fields
return {
  "rmagatti/auto-session",
  config = function()
    local function close_nvim_tree()
      require("neo-tree.command").execute({
        -- https://github.com/nvim-neo-tree/neo-tree.nvim/blob/main/lua/neo-tree/command/init.lua#L23
        action = "close",
      })
    end
    local function open_nvim_tree()
      require("neo-tree.command").execute({
        -- https://github.com/nvim-neo-tree/neo-tree.nvim/blob/main/lua/neo-tree/command/init.lua#L23
        action = "show",
      })
    end

    -- auto-session basically fails for opened neo-tree for sessions_dir
    -- so we need to close the neo-tree before auto-session saves a session
    -- and open the neo-tree when it restores a session
    require("auto-session").setup({
      log_level = error,
      pre_save_cmds = { close_nvim_tree },
      post_save_cmds = { open_nvim_tree },
      post_open_cmds = { open_nvim_tree },
      post_restore_cmds = { open_nvim_tree },
      auto_save_enabled = true,
      auto_restore_enabled = true,
      auto_session_suppress_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" },
      cwd_change_handling = {
        restore_upcoming_session = true,
        pre_cwd_changed_hook = close_nvim_tree,
        post_cwd_changed_hook = open_nvim_tree,
      },
    })

    local keymap = vim.keymap

    keymap.set("n", "<leader>wr", "<cmd>SessionRestore<CR>", { desc = "Restore session for cwd" }) -- restore last workspace session for current directory
    keymap.set("n", "<leader>ws", "<cmd>SessionSave<CR>", { desc = "Save session for auto session root dir" }) -- save workspace session for current working directory
  end,
}
