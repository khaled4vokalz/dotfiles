return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "saghen/blink.cmp",
    -- { "antosha417/nvim-lsp-file-operations", config = true },
  },
  config = function()
    local lspconfig = require("lspconfig")

    local keymap = vim.keymap -- for conciseness

    local opts = { noremap = true, silent = true }
    local on_attach = function(client, bufnr)
      opts.buffer = bufnr

      -- set keybindings
      opts.desc = "Show LSP references"
      keymap.set("n", "gR", "<cmd>FzfLua lsp_references<CR>", opts) -- show definition, references

      opts.desc = "Go to declaration"
      keymap.set("n", "gd", vim.lsp.buf.definition, opts) -- go to declaration

      opts.desc = "Show LSP definitions"
      keymap.set("n", "<leader>gd", "<cmd>FzfLua lsp_definitions<CR>", opts) -- show lsp definitions

      opts.desc = "Show LSP implementations"
      keymap.set("n", "gi", "<cmd>FzfLua lsp_implementations<CR>", opts) -- show lsp implementations

      opts.desc = "Show LSP type definitions"
      keymap.set("n", "gt", "<cmd>FzfLua lsp_type_definitions<CR>", opts) -- show lsp type definitions

      opts.desc = "See available code actions"
      keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

      opts.desc = "Smart rename"
      keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

      opts.desc = "Show buffer diagnostics"
      keymap.set("n", "<leader>D", "<cmd>FzfLua lsp_document_diagnostics<CR>", opts) -- show  diagnostics for file

      opts.desc = "Show line diagnostics"
      keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

      opts.desc = "Go to previous diagnostic"
      keymap.set("n", "gpd", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

      opts.desc = "Go to next diagnostic"
      keymap.set("n", "gnd", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

      opts.desc = "Show documentation for what is under cursor"
      keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

      opts.desc = "Restart LSP"
      keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
    end

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = require("blink.cmp").get_lsp_capabilities()

    -- Change the Diagnostic symbols in the sign column (gutter)
    -- (not in youtube nvim video)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- START: configure common language servers that don't require custom configs
    local servers = {
      "cssls",
      "jsonls",
      "bashls",
      "yamlls",
      "lemminx",
      "pyright",
      "graphql",
      "rust_analyzer",
      "gopls",
      "dockerls",
    }

    for _, lsp in ipairs(servers) do
      lspconfig[lsp].setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })
    end
    -- END
    local util = require("lspconfig.util")
    local root_dir = util.root_pattern(".git")
    lspconfig["ts_ls"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
      root_dir = root_dir,
      -- we need to manually define some custom file types, else it conflicts with angularls
      -- and as a result the angular template navigations (go to definition etc.) to typescript files does not work
      filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
    })

    -- configure angular server
    lspconfig["angularls"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
      root_dir = root_dir,
      filetypes = { "html" },
    })

    lspconfig["eslint"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
      root_dir = root_dir,
    })

    lspconfig["jdtls"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
      root_dir = root_dir,
    })
    -- configure lua server (with special settings)
    lspconfig["lua_ls"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = { -- custom settings for lua
        Lua = {
          -- make the language server recognize "vim" global
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            -- make language server aware of runtime files
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
          },
        },
      },
    })
  end,
}
