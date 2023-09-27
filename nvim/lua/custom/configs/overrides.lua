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
  ensure_installed = {
    "lua-language-server",
    "stylua",
    "css-lsp",
    "textlint",
    "jsonlint",
    "html-lsp",
    "deno",
    "prettier",
    "golangci-lint-langserver",
    "clang-format",
    "clangd",
    "gopls",
    "golangci-lint",
    "bash-language-server",
    "omnisharp",
    "ltex-ls",
    "markdownlint",
    "texlab",
    "grammarly-languageserver",
    "vtsls",
    "gofumpt",
    "goimports",
    "json-lsp",
    "sqls",
    "yamlfmt",
    "shfmt",
    "latexindent",
    "jq",
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
