return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    {
      "nvim-telescope/telescope-live-grep-args.nvim",
      -- This will not install any breaking changes.
      -- For major updates, this must be adjusted manually.
      version = "^1.0.0",
    },
  },
  config = function()
    require("telescope").load_extension("live_grep_args")
    require("telescope").load_extension("neoclip")
    -- set keymaps
    local keymap = vim.keymap -- for conciseness
    keymap.set(
      "n",
      "<leader>fg",
      ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
      { desc = "Find using grep" }
    )
    keymap.set(
      "n",
      "<C-n>",
      ":lua require('telescope').extensions.neoclip.default()<CR>",
      { noremap = true, silent = true, desc = "Find clips" }
    )
  end,
}
