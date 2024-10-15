-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("config.options")
require("config.keymaps")
require("config.custom")

-- vim.cmd([[
-- augroup jdtls_lsp
--     autocmd!
--     autocmd FileType java lua require'jdtls.jdtls_setup'.setup()
-- augroup end
-- ]])
