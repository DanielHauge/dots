return {
  {
    "dlyongemallo/diffview-plus.nvim",
    version = "*",

    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggle",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewFileHistory",
    },

    keys = {
      -- Working tree: index <-> working tree
      {
        "<leader>gd",
        "<cmd>DiffviewOpen<cr>",
        desc = "Git diff",
      },

      -- What am I about to commit?
      {
        "<leader>gs",
        "<cmd>DiffviewOpen --cached<cr>",
        desc = "Git staged diff",
      },

      -- Review current branch like a merge request
      {
        "<leader>gr",
        "<cmd>DiffviewOpen origin/main...HEAD --imply-local<cr>",
        desc = "Git branch review",
      },

      -- Current file history
      {
        "<leader>gh",
        "<cmd>DiffviewFileHistory %<cr>",
        desc = "Git file history",
      },

      -- Whole repository history
      {
        "<leader>gH",
        "<cmd>DiffviewFileHistory<cr>",
        desc = "Git repo history",
      },

      {
        "<leader>gc",
        "<cmd>DiffviewClose<cr>",
        desc = "Close diffview",
      },
    },

    opts = {
      enhanced_diff_hl = true,

      view = {
        default = {
          layout = "diff2_horizontal",
        },

        merge_tool = {
          layout = "diff3_horizontal",
        },

        file_history = {
          layout = "diff2_horizontal",
        },
      },

      file_panel = {
        listing_style = "tree",

        tree_options = {
          flatten_dirs = true,
          folder_statuses = "only_folded",
        },

        win_config = {
          position = "left",
          width = 35,
        },
      },
    },
  },
}
