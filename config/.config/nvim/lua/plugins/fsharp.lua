return {
  {
    "adelarsq/neofsharp.vim",
    ft = { "fsharp" },
  },

  -- Ensure fsautocomplete is installed via mason
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      table.insert(opts.ensure_installed, "fsautocomplete")
    end,
  },

  -- Setup LSP config to use fsautocomplete for F#
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        fsautocomplete = {
          -- You can configure fsautocomplete options here if needed
          -- e.g., settings = { fsautocomplete = {...} }
        },
      },
    },
  },
}
