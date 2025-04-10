local dap = require "dap"

-- Installations: https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation

--- C# / F# / .NET
dap.adapters.netcoredbg = {
    type = "executable",
    name = "netcoredbg",
    -- Setup command to use netcoredbg from mason install
    command = vim.fn.stdpath "data" .. "/mason/packages/netcoredbg/netcoredbg",
    -- command = "netcoredbg",
    args = { "--interpreter=vscode" },
}

-- https://github.com/nvim-neotest/neotest
-- https://github.com/Issafalcon/neotest-dotnet

dap.configurations.cs = {
    {
        name = "Launch - netcoredbg",
        type = "netcoredbg",
        request = "launch",
        program = function()
            local builds = vim.fn.system { "dotnet", "build" }
            local lines = vim.split(builds, "\n")
            print("Rebuild solution - " .. lines[#lines - 1])
            local sln = vim.fn.system { "dotnet", "sln", "list" }
            local lines = vim.split(sln, "\n")
            local projects = {}
            local choice = -1
            for i = 3, #lines do
                local project = lines[i]:match "([^%s]+).*$"
                if project then
                    project = project:sub(1, #project - 7)
                    -- if project ends with runner, use that
                    if project:match "runner" then
                        print "runner found"
                        choice = i - 2
                    end
                    table.insert(projects, i - 2, project)
                end
            end

            if choice < 0 then
                -- print each project
                for i = 1, #projects do
                    print(i .. ": " .. projects[i])
                end
                choice = vim.fn.input "Choose project: "
            end
            local project = projects[tonumber(choice)]
            project = project:match "([^/\\]+)$"
            local dll = vim.fn.glob(vim.fn.getcwd() .. "/**/bin/Debug/**/" .. project .. ".dll", true, true)
            if #dll == 0 then
                dll = vim.fn.glob(vim.fn.getcwd() .. "/**/bin/Release/**/" .. project .. ".dll", true, true)
            end
            if #dll == 0 then
                error("Could not find dll: " .. dll .. ", try rebuild")
            end
            print(dll[1])
            return dll[1]
        end,
        cwd = "${workspaceFolder}",
        args = function()
            -- get string as make args array
            local args = vim.fn.input "Arguments: "
            return vim.split(args, " ")
        end,
        stopOnEntry = false,
    },
}

dap.configurations.fsharp = dap.configurations.cs

-- Dart / Flutter
dap.adapters.dart = {
    type = "executable",
    command = "dart",
    args = { "debug_adapter" },
}
dap.adapters.flutter = {
    type = "executable",
    command = "flutter",
    args = { "debug_adapter" },
}
dap.configurations.dart = {
    {
        type = "dart",
        request = "launch",
        name = "Launch dart",
        dartSdkPath = "/opt/flutter/bin/cache/dart-sdk/bin/dart", -- ensure this is correct
        flutterSdkPath = "/opt/flutter/bin/flutter",          -- ensure this is correct
        program = "${workspaceFolder}/lib/main.dart",         -- ensure this is correct
        cwd = "${workspaceFolder}",
    },
    {
        type = "flutter",
        request = "launch",
        name = "Launch flutter",
        dartSdkPath = "/opt/flutter/bin/cache/dart-sdk/bin/dart", -- ensure this is correct
        flutterSdkPath = "/opt/flutter/bin/flutter",          -- ensure this is correct
        program = "${workspaceFolder}/lib/main.dart",         -- ensure this is correct
        cwd = "${workspaceFolder}",
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
dap.configurations.rust = {
    {
        name = "Launch file",
        request = "launch",
        type = "codelldb",
        program = function()
            -- from vim.fn.getcwd()
            local debug_path = vim.fn.getcwd() .. "/target/debug/"
            -- Find executable files in debug folder
            local files = vim.fn.glob(debug_path .. "*", true, true)
            -- Only files
            files = vim.tbl_filter(function(file)
                return vim.fn.isdirectory(file) == 0
            end, files)
            -- Only executable files
            files = vim.tbl_filter(function(file)
                return vim.fn.executable(file) == 1
            end, files)
            local choices = {}
            for _, file in ipairs(files) do
                local name = file:match "([^/\\]+)$"
                table.insert(choices, name)
            end
            if #choices == 0 then
                error("No executables found in " .. debug_path)
            end
            -- If there is only 1 executable, use that
            if #choices == 1 then
                return debug_path .. choices[1]
            end
            local choice = vim.fn.inputlist(choices)
            return debug_path .. choices[choice]

            -- return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
    },
}

-- BASH

dap.adapters.bashdb = {
    type = "executable",
    command = vim.fn.stdpath "data" .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb",
    name = "bashdb",
}

dap.configurations.sh = {
    {
        type = "bashdb",
        request = "launch",
        name = "Launch file",
        showDebugOutput = true,
        pathBashdb = vim.fn.stdpath "data" .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb",
        pathBashdbLib = vim.fn.stdpath "data" .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir",
        trace = true,
        file = "${file}",
        program = "${file}",
        cwd = "${workspaceFolder}",
        pathCat = "cat",
        pathBash = "bash",
        pathMkfifo = "mkfifo",
        pathPkill = "kill",
        args = {},
        env = {},
        terminalKind = "integrated",
    },
}

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
