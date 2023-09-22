---@type MappingsTable
local M = {}
M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
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
