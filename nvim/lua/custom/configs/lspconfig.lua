local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
-- if you just want default config for the servers then put them in a table
local servers = {
  "clangd",
  "jqls",
  "jsonls",
  "bashls",
  "pylsp",
  "cssls",
  "cucumber_language_server",
  "dockerls",
  "html",
  "csharp_ls",
  "omnisharp",
  "texlab",
  "vtsls",
  "golangci_lint_ls",
}

lspconfig["gopls"].setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    gopls = {
      gofumpt = true,
    },
  },
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

lspconfig["jsonls"].setup {
  settings = {
    json = {
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
    },
  },
}

lspconfig["yamlls"].setup {
  settings = {
    yaml = {
      schemaStore = {
        -- Must disable built-in schemaStore support if you want to use
        -- this plugin and its advanced options like `ignore`.
        enable = false,
        -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
        url = "",
      },
      schemas = require("schemastore").yaml.schemas(),
    },
  },
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

-- lsp_zero.setup_servers(servers)

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end
