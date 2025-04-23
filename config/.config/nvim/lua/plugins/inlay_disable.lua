-- ~/.config/nvim/lua/plugins/lsp.lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = false, -- disable by default
      },
      setup = {
        -- Prevent LazyVim from auto-enabling inlay hints
        ["*"] = function(_, opts)
          local ih = vim.lsp.buf.inlay_hint or vim.lsp.inlay_hint
          if type(ih) == "function" then
            vim.api.nvim_create_autocmd("LspAttach", {
              callback = function(args)
                local bufnr = args.buf
                -- Disable by default
                ih(bufnr, false)
              end,
            })
          end
        end,
      },
    },
  },
}
