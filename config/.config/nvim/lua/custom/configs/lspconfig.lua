local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
-- if you just want default config for the servers then put them in a table
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
--
-- dotnet tool install --global fsautocomplete
local servers = {
    -- "clangd",
    "jqls",
    "jsonls",
    "bashls",
    "pylsp",
    "cssls",
    "cucumber_language_server",
    "dockerls",
    "html",
    -- "ltex",
    "rust_analyzer",
    -- "texlab",
    "ts_ls",
    "sqlls",
    "csharp_ls",
    "golangci_lint_ls",
    "dockerls",
    "jdtls",
    "docker_compose_language_service",
    -- "ltex-ls",
    "fsautocomplete",
    "neocmake",
    "marksman",
    "zls",
    "templ",
    "terraformls",
}
--

-- lspconfig["texlab"].setup {
--     on_attach = on_attach,
--     capabilities = capabilities,
--     settings = {
--         texlab = {
--             latexFormatter = "texlab",
--         },
--     },
-- }

vim.api.nvim_create_autocmd("FileType", {
    pattern = "ebnf",
    callback = function()
        local tclient = vim.lsp.start_client {
            name = "ebnf-lsp",
            cmd = { "ebnf-lsp.exe" },
            on_attach = require("plugins.configs.lspconfig").on_attach,
            -- capabilities = capabilities,
        }

        vim.lsp.buf_attach_client(0, tclient)
    end,
})

for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
        on_attach = on_attach,
        capabilities = capabilities,
    }
end

-- Special snowflake LSP setups

lspconfig["gopls"].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        gopls = {
            gofumpt = true,
        },
    },
}

-- lspconfig["grammar_guard"].setup {
--     on_attach = on_attach,
--     capabilities = capabilities,
--     settings = {
--         ltex = {
--             enabled = { "latex", "tex", "bib", "markdown" },
--             language = "en",
--             diagnosticSeverity = "information",
--             setenceCacheSize = 2000,
--             additionalRules = {
--                 enablePickyRules = true,
--                 motherTongue = "en",
--             },
--             trace = { server = "verbose" },
--             dictionary = {},
--             disabledRules = {},
--             hiddenFalsePositives = {},
--         },
--     },
-- }

require("typescript-tools").setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        separate_diagnostic_server = true,
        publish_diagnostic_on = "insert_leave",
        expose_as_code_action = "all",
        tsserver_path = nil,
        tsserver_plugins = {},
        tsserver_max_memory = "auto",
        tsserver_format_options = {
            semicolons = "remove",
        },
        tsserver_file_preferences = {},
        complete_function_calls = false,
        include_completions_with_insert_text = true,
        code_lens = "off",
        disable_member_code_lens = true,
    },
}

lspconfig["clangd"].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = {
        "clangd",
        "--offset-encoding=utf-16",
        -- "--background-index",
        -- "--clang-tidy",
        -- "--completion-style=bundled",
        -- "--cross-file-rename",
        -- "--header-insertion=iywu",
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
                enable = false,
                url = "",
            },
            schemas = require("schemastore").yaml.schemas(),
        },
    },
}
