local dap = require "dap"

--- C# / F# / .NET
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
            return vim.fn.input("Path to dll", vim.fn.getcwd(), "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
    },
}

--- GOLANG
require("dap-go").setup {
    dap_configurations = {
        {
            type = "go",
            name = "Attach remote",
            mode = "remote",
            request = "attach",
        },
    },
    delve = {
        path = "dlv",
        initialize_timeout_sec = 20,
        port = "${port}",
        args = {},
        build_flags = "",
    },
}
dap.adapters.go = {
    type = "executable",
    command = "node",
    args = { vim.fn.stdpath "data" .. "/mason/packages/go-debug-adapter/extension/dist/debugAdapter.js" },
}
dap.configurations.go = {
    {
        type = "go",
        name = "Debug",
        request = "launch",
        showLog = true,
        program = "${file}",
        dlvToolPath = vim.fn.exepath "dlv",
    },
}
return dap
