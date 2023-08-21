-- set leader key to space
vim.g.mapleader = " "

-- Set leader pv to go back to directory view
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- set CTRL+Backspace to delete previous word in insert mode
vim.keymap.set('i', '<C-H>', '<C-W>', {noremap = true})

-- Set CTRL+Del to delete next word in insert mode
vim.keymap.set('i', '<C-Del>', '<C-O>dw', {noremap = true})