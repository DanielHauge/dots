-- local autocmd = vim.api.nvim_create_autocmd
-- Auto resize panes when resizing nvim window
-- autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })
--

vim.opt.spelllang = "en_us"
vim.opt.spell = true
vim.opt.guicursor =
"n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait400-blinkoff200-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Set git integration in the explorer
vim.g.nvim_tree_git_hl = 1

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv "HOME" .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 3
vim.opt.signcolumn = "yes"
vim.opt.isfname:append "@-@"

vim.opt.updatetime = 50

-- vim.opt.colorcolumn = "80"

vim.opt.autoindent = true
vim.opt.cursorline = true
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.shell = "bash.exe"
vim.opt.shellcmdflag = "-c -t -i -l -m"

vim.cmd [[
augroup ShellScript
  autocmd!
  autocmd BufWritePre *.sh set ff=unix
augroup END
]]
