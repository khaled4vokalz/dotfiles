return {
  "kevinhwang91/nvim-ufo",
  dependencies = {
    {
      "kevinhwang91/promise-async",
      {
        "luukvbaal/statuscol.nvim",
        -- the below config is needed to hide the statuscolumn
        -- for the ufo plugin which shows weird numbers for fold blocks
        config = function()
          local builtin = require("statuscol.builtin")
          require("statuscol").setup({
            relculright = true,
            segments = {
              { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
              { text = { "%s" }, click = "v:lua.ScSa" },
              { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
            },
          })
        end,
      },
    },
  },
  config = function()
    local ufo = require("ufo")
    ufo.setup({
      provider_selector = function(bufnr, filetype, buftype)
        return { "treesitter", "indent" }
      end,
    })
    vim.o.foldcolumn = "1" -- '0' is not bad
    vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
    vim.o.foldlevelstart = 99 -- to keep folds open upon opening a file
    vim.o.foldenable = true
    vim.o.foldoptions = "nodigits"
    vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

    local keymap = vim.keymap
    keymap.set("n", "zR", ufo.openAllFolds)
    keymap.set("n", "zM", ufo.closeAllFolds)
  end,
}
