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
        -- ["<leader>p"] = { "\"+p", "Paste from system clip", opts = { nowait = true}},
        ["<C-S-v>"] = { '"+p', "Paste from system clip", opts = { nowait = true } },
        ["<C-p>"] = { '""p', "Paste from system clip", opts = { nowait = true } },
        ["<S-Insert>"] = { '"+p', "Paste from system clipboard", opts = { nowait = true } },
        -- suspend vim
        ["<C-z"] = { "<cmd>lua require('utils').suspend()<CR>", "Suspend", opts = { nowait = true, noremap = true } },
        ["<leader>h"] = {
            function()
                require("hop").hint_words()
            end,
            "[H]op with word hints",
        },

        ["<leader>qd"] = {
            function()
                -- :Trouble todo filter = {tag = {TODO,FIX,FIXME}}
                require("trouble").open "todo" -- {filter = "TODO"}
            end,
            "Open Trouble Todos",
            opts = { nowait = true, noremap = true },
        },

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
        -- CTRL k is toggle lsp inlay hints
        ["<leader>k"] = {
            function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
                -- notify
                local status = vim.lsp.inlay_hint.is_enabled() and "enabled" or "disabled"
                vim.notify("Inlay hints " .. status)
            end,
            "Toggle inlay hints",
            opts = { nowait = true, noremap = true },
        },

        -- nnoremap d "zd
        -- nnoremap D "zD
        -- nnoremap c "zc
        -- nnoremap C "zC
        -- nnoremap x "zx
        ["d"] = { '"zd', "delete to register", opts = { nowait = true, noremap = true } },
        ["D"] = { '"zD', "delete to register", opts = { nowait = true, noremap = true } },
        ["c"] = { '"zc', "change to register", opts = { nowait = true, noremap = true } },
        ["C"] = { '"zC', "change to register", opts = { nowait = true, noremap = true } },
        ["x"] = { '"zx', "delete to register", opts = { nowait = true, noremap = true } },
        -- paste z on shift p
        ["<S-p>"] = { '"zp', "paste from d register", opts = { nowait = true, noremap = true } },
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
        ["<C-c>"] = { '"+y', "Copy to system clipboard", opts = { nowait = true } },

        [">"] = { "<gv", "shift right", opts = { nowait = true, noremap = true } },
        ["<"] = { ">gv", "shift left", opts = { nowait = true, noremap = true } },
        ["y"] = { '"+y', "Yank to system clipboard", opts = { nowait = true, noremap = true } },

        ["d"] = { '"zd', "delete to register", opts = { nowait = true, noremap = true } },
        ["D"] = { '"zD', "delete to register", opts = { nowait = true, noremap = true } },
        ["c"] = { '"zc', "change to register", opts = { nowait = true, noremap = true } },
        ["C"] = { '"zC', "change to register", opts = { nowait = true, noremap = true } },
        ["x"] = { '"zx', "delete to register", opts = { nowait = true, noremap = true } },
        -- paste z on shift p
        ["<S-p>"] = { '"zp', "paste from d register", opts = { nowait = true, noremap = true } },
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
        -- Control + v -> go to visual mode
        ["<C-v>"] = { "<Esc>v", "go to visual mode", opts = { nowait = true, noremap = true } },
        -- Control + shift + v to paste from system clipboard
        ["<C-p>"] = { '<C-r>"', "Paste from system clip", opts = { nowait = true } },
        -- shift p to paste from system clipboard
        ["<S-Insert>"] = { '<C-r>"', "Paste from system clipboard", opts = { nowait = true } },
    },
}
-- more ds!
return M
