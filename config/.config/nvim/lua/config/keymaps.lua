-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local unset = vim.keymap.del
unset("n", "<leader>qq")
unset("n", "<leader>qd")
unset("n", "<leader>xl")
unset("n", "<leader>xt")
unset("n", "<leader>xT")
unset("n", "<C-Down>")
unset("n", "<C-Up>")

unset("v", "<")
unset("v", ">")

-- vim.api.nvim_set_keymap('t', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true })
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode", noremap = true, silent = true })

map("v", ">", "<gv", { desc = "Indent right", nowait = true, noremap = true })
map("v", "<", ">gv", { desc = "Indent left", nowait = true, noremap = true })
-- Navigate
map("n", "<leader>/", "gcc", { desc = "Toggle comment", remap = true })
map("n", "<leader>j", "<C-d>", { desc = "Scroll down" })
map("n", "<leader>k", "<c-u>", { desc = "scroll up" })
map("n", "<leader>l", "<C-f>", { desc = "Scroll right" })
map("n", "<leader>h", "<C-b>", { desc = "Scroll left" })

-- map ctrl up and down to scroll only one line at at time
map("n", "<C-Up>", "<C-y>", { desc = "Scroll up one line" })
map("n", "<C-Down>", "<C-e>", { desc = "Scroll down one line" })
-- also ctrol + pgdn and pgup to do 10 lines like before, not cursor movement
-- DO NOT do just C-d and C-u, as that will break the scroll
map("n", "<C-PageDown>", "10<C-e>", { desc = "Scroll down 10 lines" })
map("n", "<C-PageUp>", "10<C-y>", { desc = "Scroll up 10 lines" })

-- Quick Nav w. ctl
map("n", "<C-Left>", "b", { desc = "Move left" })
map("n", "<C-Right>", "w", { desc = "Move right" })
map("n", "<C-h>", "b", { desc = "Move left" })
map("n", "<C-l>", "w", { desc = "Move right" })

-- Mpve lines up and down
map("n", "<A-j>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
map("n", "<A-Up>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
map("n", "<A-Down>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
map("i", "<A-j>", "<cmd>m .+1<CR>", { desc = "Move line down" })
map("i", "<A-k>", "<cmd>m .-2<CR>", { desc = "Move line up" })
map("i", "<A-Up>", "<cmd>m .-2<CR>", { desc = "Move line up" })
map("i", "<A-Down>", "<cmd>m .+1<CR>", { desc = "Move line down" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move line up" })
map("v", "<A-Up>", ":m '<-2<CR>gv=gv", { desc = "Move line up" })
map("v", "<A-Down>", ":m '>+1<CR>gv=gv", { desc = "Move line down" })

map("n", "<leader>pi", function()
  vim.cmd("PasteImageToDocs")
end, { desc = "Paste image to docs and add markdown" })

map("n", "<leader>x", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })

map("n", "<leader>h", function()
  require("hop").hint_words()
end, { desc = "[H]op with word hints" })

map("n", "<leader>qd", function()
  require("trouble").open("quickfix")
end, { desc = "Open Trouble Quickfix" })

-- Navigate windows
map("n", "<S-Up>", "<C-w>k", { desc = "Move up" })
map("n", "<S-Down>", "<C-w>j", { desc = "Move down" })
map("n", "<S-Left>", "<C-w>h", { desc = "Move left" })
map("n", "<S-Right>", "<C-w>l", { desc = "Move right" })

-- LSP special km
map("n", "<leader>rr", function()
  vim.lsp.buf.rename()
end, { desc = "Rename" })

-- Debuging keymaps
map("n", "<A-C-Left>", function()
  require("dap").step_back()
end, { desc = "Debug: Step Over" })
map("n", "<A-C-Right>", function()
  require("dap").step_over()
end, { desc = "Debug: Continue" })

map("n", "<A-C-Up>", function()
  require("dap").step_out()
end, { desc = "Debug: Step Into" })
map("n", "<A-C-Down>", function()
  require("dap").step_into()
end, { desc = "Debug: Step Out" })
map("n", "<A-C-Esc>", function()
  require("dap").terminate()
end, { desc = "Debug: Terminate" })

map("n", "<A-C-Enter>", function()
  require("dap").continue()
end, { desc = "Debug: Continue" })

-- Do some multi cursor studd
local mc_N = require("multicursors.normal_mode")
local mc_U = require("multicursors.utils")

-- Shift + Alt + down arrow to add cursor below using     "smoka7/multicursors.nvim",
map("n", "<A-S-Down>", function()
  local current_selections = mc_U.get_all_selections()
  if vim.tbl_isempty(current_selections) then
    vim.cmd("MCstart")
    mc_N.create_down()
  else
    mc_N.create_down()
  end
  -- if there are no selections, select the word under the cursor
end, { desc = "Multi-cursor: Start and one down" })

map("n", "<A-S-Up>", function()
  local current_selections = mc_U.get_all_selections()
  if vim.tbl_isempty(current_selections) then
    vim.cmd("MCstart")
    mc_N.create_up()
  else
    mc_N.create_up()
  end
end, { desc = "Multi-cursor: Start and one up" })

--
map("n", "<leader>tt", function()
  require("neotest").run.run()
end, { desc = "[T]est [T]his" })
map("n", "<leader>tf", function()
  require("neotest").run.run(vim.fn.expand("%"))
end, { desc = "[T]est [F]ile" })
map("n", "<leader>td", function()
  require("neotest").run.run({ strategy = "dap" })
end, { desc = "[T]est [D]ebug this" })
map("n", "<leader>ts", function()
  require("neotest").run.stop()
end, { desc = "[T]est [S]top" })

map("v", "<leader>/", "gc", { desc = "Toggle comment", remap = true })
map("v", "<leader>qq", ":Calc<CR>", { desc = "Compute selection", remap = true })

map("n", "<leader>qw", function()
  require("trouble").open("diagnostics")
end, { desc = "Open Trouble diagnostics", nowait = true, remap = true })
map("n", "<leader>qq", function()
  require("trouble").open("todo")
end, { desc = "Open Trouble LSP References", nowait = true, remap = true })
