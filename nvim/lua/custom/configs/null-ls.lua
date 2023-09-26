local null_ls = require "null-ls"

local b = null_ls.builtins

local sources = {

  -- webdev stuff
  b.formatting.prettier.with { filetypes = { "html", "markdown", "css" } }, -- so prettier works only on these filetypes

  -- Lua
  b.formatting.stylua,

  -- cpp
  b.formatting.clang_format,

  b.formatting.markdownlint,

  b.formatting.gofumpt,
  b.formatting.goimports,

  b.formatting.sqlfmt,
  b.formatting.yamlfmt,
  b.formatting.shfmt,
  b.formatting.latexindent,
  b.formatting.jq,
}

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
