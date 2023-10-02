---@type MappingsTable
local M = {}
M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
    ["<leader>qx"] = {
      function()
        require("trouble").toggle()
      end,
      "open trouble",
      opts = { nowait = true, noremap = true },
    },
    ["<leader>qw"] = {
      function()
        require("trouble").open "workspace_diagnostics"
      end,
      "Open workspace diagnostics",
      opts = { nowait = true, noremap = true },
    },
    ["<leader>qo"] = {
      function()
        require("trouble").open "document_diagnostics"
      end,
      "Open document diagnostics",
      opts = { nowait = true, noremap = true },
    },
    ["<leader>qf"] = {
      function()
        require("trouble").open "quickfix"
      end,
      "Open quickfix",
      opts = { nowait = true, noremap = true },
    },

    ["<leader>ql"] = {
      function()
        require("trouble").open "loclist"
      end,
      "Open loclist",
      opts = { nowait = true, noremap = true },
    },
    ["<leader>qr"] = {
      function()
        require("trouble").open "lsp_references"
      end,
      "Open lsp references",
      opts = { nowait = true, noremap = true },
    },
    ["<leader>qd"] = {
      function()
        require("trouble").open "lsp_definitions"
      end,
      "Open lsp definitions",
      opts = { nowait = true, noremap = true },
    },
    ["<leader>qt"] = {
      function()
        require("trouble").open "lsp_type_definitions"
      end,
      "Open lsp type definitions",
      opts = { nowait = true, noremap = true },
    },
    ["<leader>qi"] = {
      function()
        require("trouble").open "lsp_implementations"
      end,
      "Open lsp implementations",
      opts = { nowait = true, noremap = true },
    },
    ["<tab>"] = {
      "cc",
      "Inssert at current indentation",
      opts = { nowait = true, noremap = true },
    },
    ["<C-f>"] = { "<cmd> Telescope live_grep <CR>", "Live grep" },
  },

  i = {
    -- Set CTRL+Backspace to delete previous word with noremap = true
    ["<C-h>"] = { "<C-w>", "delete previous word", opts = { nowait = true, noremap = true } },
    -- Set control and backspace to delete previous word
    ["<C-BS>"] = { "<C-W>", "delete previous word", opts = { nowait = true, noremap = true } },
    --- Set F3 to format code file
    ["<F3>"] = { "<leader>fm", "format code file", opts = { nowait = true, noremap = true } },
  },
}
-- more ds!
return M
