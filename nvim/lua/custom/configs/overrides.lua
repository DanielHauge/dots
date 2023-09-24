local M = {}

M.treesitter = {
  ensure_installed = {
    "vim",
    "lua",
    "html",
    "css",
    "javascript",
    "typescript",
    "tsx",
    "c",
    "bash",
    "markdown",
    "latex",
    "markdown_inline",
    "c_sharp",
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
    "html-lsp",
    "deno",
    "prettier",
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
