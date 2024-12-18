local null_ls = require "null-ls"

local b = null_ls.builtins

local sources = {

    -- https://github.com/Carlosiano/null-ls.nvim/blob/main/doc/BUILTINS.md

    -- Lua
    b.formatting.stylua,

    -- cpp
    b.formatting.clang_format.with { filetypes = { "c", "cpp", "h", "hpp" } },

    -- Python
    b.diagnostics.ruff,
    b.formatting.isort,

    -- Docs
    b.formatting.markdownlint,
    b.diagnostics.textlint.with { filetypes = { "txt" } },

    -- Golang
    b.formatting.gofumpt,
    b.formatting.goimports,
    b.code_actions.impl,
    -- b.diagnostics.golangci_lint,

    -- C++
    b.diagnostics.cpplint,

    -- F#
    b.formatting.fantomas,

    -- markup languages
    b.formatting.yamlfmt,
    b.formatting.xmlformat,
    b.diagnostics.jsonlint,
    b.diagnostics.yamllint,

    -- Shell / Bash
    b.formatting.shfmt,
    b.code_actions.shellcheck,

    -- Typescript / Javascript
    -- b.formatting.eslint_d,
    -- b.code_actions.eslint_d,
    -- b.diagnostics.eslint_d,

    -- Misc
    b.diagnostics.actionlint,
    b.diagnostics.buf,
    b.diagnostics.commitlint,
    b.formatting.jq,
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
