-- bootstrap lazy.nvim, LazyVim and your plugins
if vim.env.NVIM_MINIMAL == "1" then
  -- Make all messages silent
  vim.opt.shortmess:append("a") -- avoid "written" messages, etc.
  vim.opt.cmdheight = 0 -- no command line
  vim.opt.showmode = false
  vim.opt.laststatus = 0 -- hide status line
  vim.opt.ruler = false -- hide ruler
  vim.opt.showcmd = false -- hide command preview

  -- Completely suppress errors/warnings/info printed by plugins
  vim.notify = function(...) end
  vim.api.nvim_err_writeln = function(...) end
  vim.api.nvim_echo = function(...) end
  vim.api.nvim_notify = function(...) end
end

require("config.highlights")
require("config.lazy")
require("config.commands")
