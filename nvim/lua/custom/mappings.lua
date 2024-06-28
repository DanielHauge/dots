---@type MappingsTable

local M = {}
M.general = {
    n = {
        -- remap PgDn to [
        ["<PageDown>"] = { "[", "PageUp", opts = { nowait = true, noremap = true } },
        -- remap PgUp to ]
        ["<PageUp>"] = { "]", "PageDown", opts = { nowait = true, noremap = true } },

        ["<C-Left>"] = { "b", "move left", opts = { nowait = true, noremap = true } },
        ["<C-Right>"] = { "w", "move right", opts = { nowait = true, noremap = true } },
        ["<C-h>"] = { "b", "move left", opts = { nowait = true, noremap = true } },
        ["<C-l>"] = { "w", "move right", opts = { nowait = true, noremap = true } },
        [";"] = { ":", "enter command mode", opts = { nowait = true } },
        ["<A-j>"] = { "<cmd>m .+1<CR>==", "move line down" },
        ["<A-k>"] = { "<cmd>m .-2<CR>==", "move line up" },
        ["<A-Up>"] = { "<cmd>m .-2<CR>==", "move line up" },
        ["<A-Down>"] = { "<cmd>m .+1<CR>==", "move line down" },

        ["<leader>h"] = {
            function()
                require("hop").hint_words()
            end,
        },

        ["<leader>qx"] = {
            function()
                require("trouble").toggle()
            end,
            "open trouble",
            opts = { nowait = true, noremap = true },
        },
        ["<leader>qw"] = {
            function()
                require("trouble").open "workspace_diagnostics"
            end,
            "Open workspace diagnostics",
            opts = { nowait = true, noremap = true },
        },
        ["<leader>qo"] = {
            function()
                require("trouble").open "document_diagnostics"
            end,
            "Open document diagnostics",
            opts = { nowait = true, noremap = true },
        },
        ["<leader>qf"] = {
            function()
                require("trouble").open "quickfix"
            end,
            "Open quickfix",
            opts = { nowait = true, noremap = true },
        },

        ["<leader>ql"] = {
            function()
                require("trouble").open "loclist"
            end,
            "Open loclist",
            opts = { nowait = true, noremap = true },
        },
        ["gr"] = {
            function()
                require("trouble").open "lsp_references"
            end,
            "Open lsp references",
            opts = { nowait = true, noremap = true },
        },
        ["gd"] = {
            function()
                require("trouble").open "lsp_definitions"
            end,
            "Open lsp definitions",
            opts = { nowait = true, noremap = true },
        },
        ["<leader>qt"] = {
            function()
                require("trouble").open "lsp_type_definitions"
            end,
            "Open lsp type definitions",
            opts = { nowait = true, noremap = true },
        },
        ["gI"] = {
            function()
                require("trouble").open "lsp_implementations"
            end,
            "Open lsp implementations",
            opts = { nowait = true, noremap = true },
        },
        -- Control + o to do new line above
        ["<A-o>"] = { "O<ESC>", "new line above", opts = { nowait = true, noremap = true } },

        -- Debugging
        ["<F5>"] = { "<cmd>lua require'dap'.continue()<CR>", "Continue", opts = { nowait = true, noremap = true } },
        ["<leader>db"] = {
            "<cmd>lua require'dap'.toggle_breakpoint()<CR>",
            "Toggle breakpoint",
            opts = { nowait = true, noremap = true },
        },
        ["<leader>dB"] = {
            "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
            "Set breakpoint with condition",
            opts = { nowait = true, noremap = true },
        },
        ["<F9>"] = { "<cmd>lua require'dap'.step_out()<CR>", "Step out", opts = { nowait = true, noremap = true } },
        ["<F10>"] = { "<cmd>lua require'dap'.step_over()<CR>", "Step over", opts = { nowait = true, noremap = true } },
        ["<F11>"] = { "<cmd>lua require'dap'.step_into()<CR>", "Step into", opts = { nowait = true, noremap = true } },
        ["<leader>ds"] = { "<cmd>lua require'dap'.close()<CR>", "Stop", opts = { nowait = true, noremap = true } },
        ["<leader>dr"] = { "<cmd>lua require'dap'.repl.open()<CR>", "Open REPL", opts = { nowait = true, noremap = true } },
        ["<leader>dl"] = { "<cmd>lua require'dap'.run_last()<CR>", "Run last", opts = { nowait = true, noremap = true } },
        ["<leader>dC"] = {
            "<cmd>lua require'dap'.disconnect();require'dap'.close();require'dapui'.close();require'dap'.clear_breakpoints();<CR>",
            "Stop and close",
            opts = { nowait = true, noremap = true },
        },
        ["<leader>dc"] = {
            "<cmd>lua require'dap'.disconnect();require'dap'.close();require'dapui'.close()<CR>",
            "Stop and close",
            opts = { nowait = true, noremap = true },
        },
        ["<S-Up>"] = { "<C-w>k", "move up", opts = { nowait = true, noremap = true } },
        ["<S-Down>"] = { "<C-w>j", "move down", opts = { nowait = true, noremap = true } },
        ["<S-Left>"] = { "<C-w>h", "move left", opts = { nowait = true, noremap = true } },
        ["<S-Right>"] = { "<C-w>l", "move right", opts = { nowait = true, noremap = true } },

        -- Neotest mappings:
        ["<leader>tt"] = {
            function()
                require("neotest").run.run()
            end,
            "[T]est [T]his",
            opts = { nowait = true, noremap = true },
        },
        ["<leader>tf"] = {
            function()
                require("neotest").run.run(vim.fn.expand "%")
            end,
            "[T]est [F]ile",
            opts = { nowait = true, noremap = true },
        },
        ["<leader>td"] = {
            function()
                require("neotest").run.run { strategy = "dap" }
            end,
            "[T]est [D]ebug this",
        },

        ["<leader>ts"] = {
            function()
                require("neotest").run.stop()
            end,
            "[T]est [S]top",
            opts = { nowait = true, noremap = true },
        },
    },

    v = {
        ["<A-j>"] = { ":m '>+1<CR>gv=gv", "move line down" },
        ["<A-k>"] = { ":m '<-2<CR>gv=gv", "move line up" },
        ["<A-Up>"] = { ":m '<-2<CR>gv=gv", "move line up" },
        ["<A-Down>"] = { ":m '>+1<CR>gv=gv", "move line down" },
        ["<C-Left>"] = { "b", "move left", opts = { nowait = true, noremap = true } },
        ["<C-Right>"] = { "w", "move right", opts = { nowait = true, noremap = true } },
        -- remap PgDn to [
        ["<PageDown>"] = { "[", "PageUp", opts = { nowait = true, noremap = true } },
        -- remap PgUp to ]
        ["<PageUp>"] = { "]", "PageDown", opts = { nowait = true, noremap = true } },
        ["<leader>c"] = {
            ":Calc<CR>",
            "Compute selection",
        },
    },

    i = {

        -- Set CTRL+Backspace to delete previous word with noremap = true
        ["<C-h>"] = { "<C-w>", "delete previous word", opts = { nowait = true, noremap = true } },
        -- Set control and backspace to delete previous word
        ["<C-BS>"] = { "<C-W>", "delete previous word", opts = { nowait = true, noremap = true } },
        ["<C-Left>"] = { "<C-Left>", "move left", opts = { nowait = true, noremap = true } },
        ["<C-Right>"] = { "<C-Right>", "move right", opts = { nowait = true, noremap = true } },
        -- remap PgDn to [
        ["<PageDown>"] = { "[", "PageUp", opts = { nowait = true, noremap = true } },
        -- remap PgUp to ]
        ["<PageUp>"] = { "]", "PageDown", opts = { nowait = true, noremap = true } },
        ["<A-j>"] = { "<cmd>m .+1<CR>", "move line down" },
        ["<A-k>"] = { "<cmd>m .-2<CR>", "move line up" },
        ["<A-Up>"] = { "<cmd>m .-2<CR>", "move line up" },
        ["<A-Down>"] = { "<cmd>m .+1<CR>", "move line down" },
        -- Control + o to do new line above, but stay in insert mode
        ["<A-o>"] = { "<Esc>O", "new line above", opts = { nowait = true, noremap = true } },
    },
}
-- more ds!
return M
