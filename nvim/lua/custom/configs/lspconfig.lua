local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"

local lsp_zero = require "lsp-zero"

---@diagnostic disable-next-line: unused-local
lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps { buffer = bufnr }
end)

-- if you just want default config for the servers then put them in a table
local servers = {
  "clangd",
  "gopls",
  "jqls",
  "jsonls",
  "bashls",
  "pylsp",
  "cucumber_language_server",
  "dockerls",
  "csharp_ls",
  "omnisharp",
  "texlab",
  "vtsls",
}

lspconfig["eslint"].setup {
  on_attach = function(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "EslintFixAll",
    })
  end,
  capabilities = capabilities,
}


-- change cmd of ltex to ltex-ls
lspconfig["ltex"].setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "ltex-ls" },
  -- settings = {
  --   -- latex = {
  --   --   build = {
  --   --     args = { "%f" },
  --   --     executable = "tex",
  --   --     onSave = true,
  --   --   },
  --   --   lint = {
  --   --     onChange = true,
  --   --   },
  --   -- },
  -- },
}

lspconfig["grammarly"].setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "markdown", "tex", "text" },
}

lsp_zero.setup_servers(servers)

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end
