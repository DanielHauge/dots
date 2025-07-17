-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- make auto command that does a command on every markdown buffer enter
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.cmd("PeekOpen")
  end,
})

vim.api.nvim_create_autocmd({ "BufReadCmd" }, {
  pattern = { "*.h5", "*.hdf5", "*.hdf", "*.pg3" },
  callback = function(args)
    local file = vim.fn.expand("%:p")

    -- Delete the buffer before it loads
    vim.schedule(function()
      vim.cmd("bdelete! " .. args.buf) -- DIdnt work
      vim.cmd("enew") -- Open an empty buffer
      vim.cmd("terminal h5v " .. vim.fn.fnameescape(file))
      vim.cmd("startinsert")
    end)
  end,
})

vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "*",
  callback = function()
    -- Check if we just left terminal insert mode
    if vim.fn.mode() == "n" then
      local buftype = vim.bo.buftype
      if buftype == "terminal" then
        -- Move cursor to last line and first column
        local last_line = vim.api.nvim_buf_line_count(0)
        vim.api.nvim_win_set_cursor(0, { last_line, 0 })
        -- Scroll to bottom
        vim.cmd("normal! zb")
      end
    end
  end,
})
