local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
-- if you just want default config for the servers then put them in a table
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
--
-- dotnet tool install --global fsautocomplete
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
    "rust_analyzer",
    "tsserver",
    "sqlls",
    "csharp_ls",
    "golangci_lint_ls",
    "dockerls",
    "jdtls",
    "docker_compose_language_service",
    "fsautocomplete",
}

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

-- change cmd of ltex to ltex-ls
lspconfig["ltex"].setup {
    on_attach = on_attach,
    capabilities = capabilities,
}

lspconfig["grammarly"].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { "markdown", "tex", "plaintex", "text" },
}
