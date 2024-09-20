local overrides = require "custom.configs.overrides"

---@type NvPluginSpec[]
local plugins = {

    {
        "b0o/schemastore.nvim",
    },
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        },
    },
    {
        "nvim-treesitter/playground",
        cmd = "TSPlaygroundToggle",
    },
    -- {
    --     "ionide/Ionide-vim",
    --     ft = { "fsharp" },
    --     config = function()
    --         local on_attach = require("plugins.configs.lspconfig").on_attach
    --         local capabilities = require("plugins.configs.lspconfig").capabilities
    --         require("ionide").setup {
    --             on_attach = on_attach,
    --             capabilities = capabilities,
    --         }
    --     end,
    -- },
    {
        "vzze/calculator.nvim",
        opt = true,
        module = "calculator",
    },
    {
        "phaazon/hop.nvim",
        branch = "v2",
        config = function()
            require("hop").setup { keys = "etovxqpdygfblzhckisuran" }
        end,
    },
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "Issafalcon/neotest-dotnet",
            -- Rust
            "rouge8/neotest-rust",
            "nvim-neotest/nvim-nio",
        },
        ft = { "csharp", "fsharp" },
        config = function()
            require("neotest").setup {
                adapters = {
                    require "neotest-dotnet",
                    require "neotest-rust",
                },
            }
        end,
    },
    {
        "adelarsq/neofsharp.vim",
        ft = { "fsharp" },
    },
    {
        "akinsho/flutter-tools.nvim",
        ft = { "dart" },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "stevearc/dressing.nvim", -- optional for vim.ui.select
        },
        config = true,
    },
    {
        "LunarVim/bigfile.nvim",
        event = "BufReadPre",
        opts = {
            filesize = 2,
        },
        config = function()
            require("bigfile").setup(opts)
        end,
    },
    {
        "Treeniks/isabelle-syn.nvim",
        lazy = false,
    },
    {
        "Treeniks/isabelle-lsp.nvim",
        dependencies = {
            "neovim/nvim-lspconfig",
        },
        ft = { "isabelle" },
    },

    {
        "ray-x/lsp_signature.nvim",
        event = "VeryLazy",
        opts = {},
        config = function(_, opts)
            require("lsp_signature").setup(opts)
        end,
    },

    {
        "samodostal/image.nvim",
        lazy = false,
        dependencies = { "nvim-lua/plenary.nvim", "m00qek/baleia.nvim" },
        opts = {
            render = {
                min_padding = 5,
                show_label = true,
                show_image_dimensions = true,
                use_dither = true,
                foreground_color = true,
                background_color = true,
            },
            events = {
                update_on_nvim_resize = true,
            },
        },
    },

    {
        "pmizio/typescript-tools.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
        opts = {},
    },
    {
        "lukas-reineke/lsp-format.nvim",
        dependencies = { "neovim/nvim-lspconfig" },
    },
    -- Override plugin definition options
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {},
        cmd = "Trouble",
        keys = {
            {
                "<leader>qx",
                "<cmd>Trouble toggle<cr>",
                desc = "Trouble toggle",
            },
            {
                "<leader>qw",
                "<cmd>Trouble diagnostics focus=true<cr>",
                desc = "Diagnostics (Trouble)",
            },
            {
                "<leader>qd",
                "<cmd>Trouble todo focus=true<cr>",
                desc = "Todos (Trouble)",
            },
            {
                "<leader>qB",
                "<cmd>Trouble diagnostics toggle filter.buf=0 focus=true<cr>",
                desc = "Buffer Diagnostics (Trouble)",
            },

            {
                "<leader>qs",
                "<cmd>Trouble symbols toggle focus=true<cr>",
                desc = "Symbols (Trouble)",
            },
            {
                "<leader>qr",
                "<cmd>Trouble lsp toggle focus=true win.position=right<cr>",
                desc = "LSP Definitions / references / ... (Trouble)",
            },
            {
                "<leader>qL",
                "<cmd>Trouble loclist toggle focus=true<cr>",
                desc = "Location List (Trouble)",
            },
            {
                "<leader>qf",
                "<cmd>Trouble qflist focus=true<cr>",
                desc = "Quickfix List (Trouble)",
            },
        },
    },
    {
        "mfussenegger/nvim-dap",
        dependencies = { "rcarriga/nvim-dap-ui" },
        config = function()
            require "custom.configs.dap"
        end,
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap" },
        -- Load when dap is loaded
        config = function()
            require "custom.configs.dap-ui"
        end,
    },
    {
        "leoluz/nvim-dap-go",
        ft = { "go" },
    },

    {
        "neovim/nvim-lspconfig",
        dependencies = {
            -- format & linting
            {
                "jose-elias-alvarez/null-ls.nvim",
                config = function()
                    require "custom.configs.null-ls"
                end,
            },
        },
        config = function()
            require "plugins.configs.lspconfig"
            require "custom.configs.lspconfig"
        end, -- Override to setup mason-lspconfig
    },

    -- override plugin configs
    {
        "williamboman/mason.nvim",
        opts = overrides.mason,
    },

    {
        "nvim-treesitter/nvim-treesitter",
        opts = overrides.treesitter,
    },

    {
        "nvim-tree/nvim-tree.lua",
        -- opts = overrides.nvimtree,
    },

    -- {
    --     "nvim-telescope/telescope-fzf-native.nvim",
    --     build =
    --     "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
    -- },

    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
    },
    {
        "antosha417/nvim-lsp-file-operations",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-neo-tree/neo-tree.nvim",
        },
    },
    { "echasnovski/mini.nvim", version = "*" },
    -- Install a plugin
    {
        "max397574/better-escape.nvim",
        event = "InsertEnter",
        config = function()
            require("better_escape").setup()
        end,
    },
}

return plugins
