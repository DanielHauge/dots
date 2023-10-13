local M = {}

-- Add custom treesitter parsers
-- Remember to run: ':TSInstallFromGrammar fsharp'
local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.fsharp = {
    install_info = {
        url = "https://github.com/Nsidorenco/tree-sitter-fsharp",
        branch = "develop",
        files = { "src/scanner.cc", "src/parser.c" },
        generate_requires_npm = true,
        requires_generate_from_grammar = true,
    },
    filetype = "fsharp",
}

M.treesitter = {
    -- https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
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
        "fsharp",
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
