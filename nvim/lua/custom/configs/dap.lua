local dap = require "dap"

print "dap.lua"

dap.adapters.coreclr = {
    type = "executable",
    -- Setup command to use netcoredbg from mason install
    command = vim.fn.stdpath "data" .. "/mason/packages/netcoredbg/netcoredbg/netcoredbg.exe",
    -- command = "netcoredbg",
    args = { "--interpreter=vscode" },
}

dap.configurations.cs = {
    {
        name = "Launch - netcoredbg",
        type = "coreclr",
        request = "launch",
        program = function()
            return vim.fn.input("Path to dll", vim.fn.getcwd() .. "/bin/Debug/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
    },
}

return dap
