vim.api.nvim_create_user_command("Calc", 'lua require("calculator").calculate()', { ["range"] = 1, ["nargs"] = 0 })
