return {
  {
    "navarasu/onedark.nvim",
    priority = 1000,
    config = function()
      local highlights = require("config.highlights")
      require("onedark").setup({
        style = "darker",
        highlights = highlights,
        -- transparent = true,
        term_colors = true,
        ending_tildes = false,
      })
    end,
    vim.api.nvim_set_hl(0, "DiagnosticUnnecessary", {
      strikethrough = true,
    }),
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "onedark",
    },
  },
}
