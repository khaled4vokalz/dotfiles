-- Command to toggle inline diagnostics
vim.api.nvim_create_user_command("DiagnosticsToggleVirtualText", function()
  local current_value = vim.diagnostic.config().virtual_text
  if current_value then
    vim.diagnostic.config({ virtual_text = false })
  else
    vim.diagnostic.config({ virtual_text = true })
  end
end, {})

-- Command to toggle diagnostics
vim.api.nvim_create_user_command("DiagnosticsToggle", function()
  local current_value = vim.diagnostic.is_enabled()
  if not current_value then
    vim.diagnostic.enable()
  else
    vim.diagnostic.enable(false)
  end
end, {})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "*" },
  callback = function()
    vim.b.autoformat = false
  end,
})

vim.api.nvim_create_user_command("ToggleAutoFormat", function()
  vim.b.autoformat = not vim.b.autoformat
  print("Autoformat is now " .. (vim.b.autoformat and "ON" or "OFF"))
end, {})
