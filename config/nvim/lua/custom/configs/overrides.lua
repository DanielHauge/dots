local M = {}

M.treesitter = {
    -- https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
    ensure_installed = {
        "vim",
        "templ",
        "lua",
        "just",
        "just",
        "html",
        "css",
        "javascript",
        "cpp",
        "java",
        "typescript",
        "make",
        "python",
        "tsx",
        "c",
        "regex",
        "pascal",
        "bash",
        "csv",
        "bibtex",
        "markdown",
        "markdown_inline",
        "dockerfile",
        "latex",
        "bibtex",
        "c_sharp",
        "go",
        "dart",
        "zig",
        "rust",
        "ebnf",
    },
    indent = {
        enable = true,
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
    ensure_installed = {
        -- Docs
        "textlint",
        "marksman",
        "latexindent",
        "markdownlint",
        "grammarly-languageserver",
        "texlab",
        "ltex-ls",

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
        "csharp-language-server",
        "omnisharp",
        "netcoredbg",
        "fantomas",
        "fsautocomplete",

        -- Dart
        "dart-debug-adapter",

        -- Java
        "jdtls",

        -- Rust
        "rust-analyzer",

        -- Markup (Data)
        "jsonlint",
        "yamllint",
        "json-lsp",
        "yaml-language-server",
        "yamlfmt",
        "jq",

        -- Python
        "python-lsp-server",
        "isort",
        "ruff",

        -- Web
        "css-lsp",
        "html-lsp",
        "prettier",
        "typescript-language-server",
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
        "go-debug-adapter",
        "delve",

        -- C/C++
        "clangd",
        "cpplint",
        "codelldb",
        "neocmakelsp",

        -- Bash
        "bash-language-server",
        "shfmt",
        "shellcheck",
        "bash-debug-adapter",
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
