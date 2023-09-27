local null_ls = require "null-ls"

local b = null_ls.builtins

local sources = {

  -- webdev stuff
  b.formatting.prettier.with { filetypes = { "html", "css" } }, -- so prettier works only on these filetypes

  -- Lua
  b.formatting.stylua,

  -- cpp
  b.formatting.clang_format,

  b.formatting.markdownlint,

  b.formatting.gofumpt,
  b.formatting.goimports,
  b.formatting.goimports_reviser,
  b.formatting.yamlfmt,
  b.formatting.shfmt,
  b.formatting.latexindent,
  b.formatting.eslint_d,
  b.code_actions.eslint_d,
  b.code_actions.impl,
  b.formatting.jq,
  b.diagnostics.actionlint,
  b.diagnostics.buf,
  b.diagnostics.commitlint,
  b.diagnostics.eslint_d,
  b.diagnostics.golangci_lint,
  b.formatting.xmlformat,
  b.diagnostics.jsonlint,
  b.diagnostics.textlint.with { filetypes = { "txt" } },
  b.formatting.textlint.with { filetypes = { "txt" } },
  b.diagnostics.write_good,
  b.diagnostics.yamllint,
}

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

null_ls.setup {
  debug = true,
  sources = sources,
  on_attach = function(client, bufnr)
    if client.supports_method "textDocument/formatting" then
      vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format { async = false }
        end,
      })
    end
  end,
}
