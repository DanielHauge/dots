local minimal = vim.env.NVIM_MINIMAL == "1"
return {
  {
    "neovim/nvim-lspconfig",
    enabled = not minimal, -- Disable LSP config in minimal mode
  },
}
