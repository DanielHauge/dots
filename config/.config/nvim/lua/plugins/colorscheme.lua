return {
  {
    "navarasu/onedark.nvim",
    priority = 1000,
    config = function()
      local highlights = require("config.highlights")
      require("onedark").setup({
        style = "dark",
        highlights = highlights,
        diagnostics = {
          darker = true,
          undercurl = true,
          background = true,
          strikethrough = true,
        },
        term_colors = true,
        ending_tildes = true,
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "onedark",
    },
  },
}
