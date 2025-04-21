return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "Issafalcon/neotest-dotnet",
      -- Rust
      "rouge8/neotest-rust",
      "nvim-neotest/nvim-nio",
    },
    ft = { "csharp", "fsharp" },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-dotnet"),
          require("neotest-rust"),
        },
      })
    end,
  },
  {
    "adelarsq/neofsharp.vim",
    ft = { "fsharp" },
  },
}
