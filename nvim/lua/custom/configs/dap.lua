local dap = require "dap"

-- Installations: https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation

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
            local sln = vim.fn.system { "dotnet", "sln", "list" }
            local lines = vim.split(sln, "\n")
            local projects = {}
            for i = 3, #lines do
                local project = lines[i]:match "([^%s]+).*$"
                if project then
                    project = project:sub(1, #project - 7)
                    table.insert(projects, i - 2, project)
                    print(i - 2 .. ": " .. project)
                end
            end
            local choice = vim.fn.input "Choose project: "
            local project = projects[tonumber(choice)]
            local dll = vim.fn.glob(vim.fn.getcwd() .. "/**/bin/Debug/**/" .. project .. ".dll", true, true)
            if #dll == 0 then
                dll = vim.fn.glob(vim.fn.getcwd() .. "/**/bin/Release/**/" .. project .. ".dll", true, true)
            end
            if #dll == 0 then
                error "Could not find dll, try rebuild"
            end
            print(dll[1])
            return dll[1]
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
    },
}

--- C / C++
dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    executable = {
        command = vim.fn.stdpath "data" .. "/mason/packages/codelldb/extension/adapter/codelldb",
        args = { "--port", "${port}" },
        detached = false,
    },
}
dap.configurations.cpp = {
    {
        name = "Launch file",
        type = "codelldb",
        request = "launch",
        program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
    },
}
dap.configurations.c = dap.configurations.cpp

--- GOLANG
-- Uses plugin to start delve in debug mode and attach to adapter.
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
