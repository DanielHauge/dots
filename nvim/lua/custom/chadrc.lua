---@type ChadrcConfig
local M = {}

-- Path to overriding theme and highlights files
local highlights = require "custom.highlights"

M.ui = {
    theme = "onedark",
    hl_override = highlights.override,
    hl_add = highlights.add,

    -- https://github.com/NvChad/base46/tree/v2.0/lua/base46/extended_integrations
    extended_integrations = { "trouble" }, -- these aren't compiled by default, ex: "alpha", "notify"
    telescope = { style = "bordered" },
}

M.plugins = "custom.plugins"

-- check core.mappings for table structure
M.mappings = require "custom.mappings"

return M
