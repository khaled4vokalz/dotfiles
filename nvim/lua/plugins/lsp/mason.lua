return {
  "williamboman/mason.nvim",
  dependencies = {
    "jose-elias-alvarez/null-ls.nvim",
    "jayp0521/mason-null-ls.nvim",
    "mason-org/mason-lspconfig.nvim",
  },
  config = function()
    -- import mason
    local mason = require("mason")

    -- import mason-lspconfig
    local mason_lspconfig = require("mason-lspconfig")

    -- import mason-null-ls
    local mason_null_ls = require("mason-null-ls")

    -- enable mason and configure icons
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_lspconfig.setup({
      -- list of servers for mason to install
      ensure_installed = {
        "bashls",
        "eslint",
        "ts_ls",
        "bashls",
        "angularls",
        "html",
        "jsonls",
        "cssls",
        "tailwindcss",
        "lua_ls",
        "graphql",
        "pyright",
        "yamlls",
        "lemminx",
        "jdtls",
        "gopls",
        "dockerls",
        "golangci-lint",
      },
      -- auto-install configured servers (with lspconfig)
      automatic_installation = true, -- not the same as ensure_installed
    })

    mason_null_ls.setup({
      -- list of formatters & linters for mason to install
      ensure_installed = {
        "prettier", -- ts/js formatter
        "stylua", -- lua formatter
        "eslint", -- ts/js linter
        "shfmt",
        "shellcheck",
      },
      -- auto-install configured servers (with lspconfig)
      automatic_installation = true,
    })
  end,
}
