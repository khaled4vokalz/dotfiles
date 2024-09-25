local keymap = vim.keymap -- for conciseness

keymap.set("n", "sa", "gg<S-v><S-g>", { desc = "select all in current buffer" })

-- keep visual selection when (de)indenting
keymap.set("v", ">", ">gv", {})
keymap.set("v", "<", "<gv", {})

-- window management
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

keymap.set("n", "<leader>vt", "<cmd>DiagnosticsToggleVirtualText<CR>", { desc = "Toggle diagnostic virtual texts" })

keymap.set("n", "<leader>dd", function()
  vim.diagnostic.open_float()
end, { noremap = true, desc = "Open floating diagnostics window" }) --  move current buffer to new tab

-- don't yank text on pasting over selection
keymap.set("x", "p", "P", { silent = true })

keymap.set("n", "<leader>far", function()
  vim.lsp.buf.references()
end, { noremap = true, desc = "Find all references " })
