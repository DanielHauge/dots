local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
-- if you just want default config for the servers then put them in a table
local servers = {
    "clangd",
    "jqls",
    "jsonls",
    "bashls",
    "pylsp",
    "cssls",
    "cucumber_language_server",
    "dockerls",
    "html",
    "csharp_ls",
    "omnisharp",
    "texlab",
    "golangci_lint_ls",
}

lspconfig["gopls"].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        gopls = {
            gofumpt = true,
        },
    },
}

require("typescript-tools").setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        -- spawn additional tsserver instance to calculate diagnostics on it
        separate_diagnostic_server = true,
        -- "change"|"insert_leave" determine when the client asks the server about diagnostic
        publish_diagnostic_on = "insert_leave",
        -- array of strings("fix_all"|"add_missing_imports"|"remove_unused"|
        -- "remove_unused_imports"|"organize_imports") -- or string "all"
        -- to include all supported code actions
        -- specify commands exposed as code_actions
        expose_as_code_action = "all",
        -- string|nil - specify a custom path to `tsserver.js` file, if this is nil or file under path
        -- not exists then standard path resolution strategy is applied
        tsserver_path = nil,
        -- specify a list of plugins to load by tsserver, e.g., for support `styled-components`
        -- (see 💅 `styled-components` support section)
        tsserver_plugins = {},
        -- this value is passed to: https://nodejs.org/api/cli.html#--max-old-space-sizesize-in-megabytes
        -- memory limit in megabytes or "auto"(basically no limit)
        tsserver_max_memory = "auto",
        -- described below
        tsserver_format_options = {
            semicolons = "remove",
        },
        tsserver_file_preferences = {},
        -- mirror of VSCode's `typescript.suggest.completeFunctionCalls`
        complete_function_calls = false,
        include_completions_with_insert_text = true,
        -- CodeLens
        -- WARNING: Experimental feature also in VSCode, because it might hit performance of server.
        -- possible values: ("off"|"all"|"implementations_only"|"references_only")
        code_lens = "off",
        -- by default code lenses are displayed on all referencable values and for some of you it can
        -- be too much this option reduce count of them by removing member references from lenses
        disable_member_code_lens = true,
    },
}

lspconfig["eslint"].setup {
    on_attach = function(_, bufnr)
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
        })
    end,
    capabilities = capabilities,
}

lspconfig["jsonls"].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
        },
    },
}

lspconfig["yamlls"].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        yaml = {
            schemaStore = {
                -- Must disable built-in schemaStore support if you want to use
                -- this plugin and its advanced options like `ignore`.
                enable = false,
                -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                url = "",
            },
            schemas = require("schemastore").yaml.schemas(),
        },
    },
}

-- change cmd of ltex to ltex-ls
lspconfig["ltex"].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = { "ltex-ls" },
    -- settings = {
    --   -- latex = {
    --   --   build = {
    --   --     args = { "%f" },
    --   --     executable = "tex",
    --   --     onSave = true,
    --   --   },
    --   --   lint = {
    --   --     onChange = true,
    --   --   },
    --   -- },
    -- },
}

lspconfig["grammarly"].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { "markdown", "tex", "text" },
}

-- lsp_zero.setup_servers(servers)

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
        on_attach = on_attach,
        capabilities = capabilities,
    }
end
