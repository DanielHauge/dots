local M = {}

M.treesitter = {
    ensure_installed = {
        "vim",
        "lua",
        "html",
        "css",
        "javascript",
        "typescript",
        "python",
        "tsx",
        "c",
        "regex",
        "bash",
        "markdown",
        "latex",
        "markdown_inline",
        "c_sharp",
        "go",
    },
    indent = {
        enable = true,
        -- disable = {
        --   "python"
        -- },
    },
}

M.mason = {
    -- https://mason-registry.dev/registry/list
    ensure_installed = {
        -- Docs
        "textlint",
        "ltex-ls",
        "latexindent",
        "markdownlint",
        "texlab",
        "grammarly-languageserver",

        -- Misc
        "commitlint",
        "cucumber-language-server",
        "buf",
        "actionlint",

        -- Lua
        "lua-language-server",
        "stylua",

        -- C#/F#
        "fautocomplete",
        "fantomas",
        "omnisharp",
        "netcoredbg",

        -- Markup (Data)
        "jsonlint",
        "yamllint",
        "json-lsp",
        "yaml-language-server",
        "yamlfmt",
        "jq",

        -- Web
        "css-lsp",
        "html-lsp",
        "prettier",
        "tsserver",
        "eslint_d",
        "eslint-lsp",

        -- Golang
        "golangci-lint-langserver",
        "golangci-lint",
        "gopls",
        "gofumpt",
        "goimports",
        "impl", -- Go interface implementation
        "templ",

        -- C/C++
        "clang-format",
        "clangd",

        -- Bash
        "bash-language-server",
        "shfmt",
    },
}

-- git support in nvimtree
M.nvimtree = {
    git = {
        enable = true,
    },

    renderer = {
        highlight_git = true,
        icons = {
            show = {
                git = true,
            },
        },
    },
}

return M
