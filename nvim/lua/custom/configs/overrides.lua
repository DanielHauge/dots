local M = {}

-- Add custom treesitter parsers
-- Remember to run: ':TSInstallFromGrammar fsharp'

M.treesitter = {
    -- https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
    ensure_installed = {
        "vim",
        "lua",
        "html",
        "css",
        "javascript",
        "java",
        "typescript",
        "make",
        "python",
        "tsx",
        "c",
        "regex",
        "bash",
        "csv",
        "markdown",
        "markdown_inline",
        "dockerfile",
        "latex",
        "bibtex",
        "c_sharp",
        "go",
        "dart",
    },
    indent = {
        enable = true,
        -- disable = {
        --   "python"
        -- },
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            node_incremental = "v",
            node_decremental = "V",
        },
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
        "grammarly-languageserver",

        -- Misc
        "commitlint",
        "cucumber-language-server",
        "sqlls",
        "buf",
        "actionlint",
        "dockerfile-language-server",
        "docker-compose-language-service",

        -- Lua
        "lua-language-server",
        "stylua",

        -- C#/F#
        "fautocomplete",
        "fantomas",
        "csharp-language-server",
        "omnisharp",
        "netcoredbg",

        -- Java
        "jdtls",

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
