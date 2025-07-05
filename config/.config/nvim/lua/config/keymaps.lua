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

unset("v", "<")
unset("v", ">")

map("v", ">", "<gv", { desc = "Indent right", nowait = true, noremap = true })
map("v", "<", ">gv", { desc = "Indent left", nowait = true, noremap = true })
-- Navigate
map("n", "<leader>/", "gcc", { desc = "Toggle comment", remap = true })
map("n", "<leader>j", "<C-d>", { desc = "Scroll down" })
map("n", "<leader>k", "<c-u>", { desc = "scroll up" })
map("n", "<leader>l", "<C-f>", { desc = "Scroll right" })
map("n", "<leader>h", "<C-b>", { desc = "Scroll left" })

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

-- Test keymaps
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
