-- To find any highlight groups: "<cmd> Telescope highlights"
-- Each highlight group can take a table with variables fg, bg, bold, italic, etc
-- base30 variable names can also be used as colors

-- Make unnecesary / unused variables less visible
vim.api.nvim_set_hl(0, "DiagnosticUnnecessary", {
    strikethrough = true,
})

-- Override custom nvim-treesitter highlight group links
-- TYPESCRIPT overrides
vim.api.nvim_set_hl(0, "@type.qualifier.typescript", { link = "@keyword" })
vim.api.nvim_set_hl(0, "@lsp.type.class.typescript", { link = "Type" })
vim.api.nvim_set_hl(0, "@lsp.type.interface.typescript", { fg = "#aef9b0" })
vim.api.nvim_set_hl(0, "@lsp.type.enum.typescript", { fg = "#d25505" })

-- C# Overrides
-- vim.api.nvim_set_hl(1, "@lsp.type.keyword.cs", { link = "@keyword" })
vim.api.nvim_set_hl(0, "@lsp.type.class.cs", { link = "@type" })
vim.api.nvim_set_hl(0, "@lsp.type.parameter.cs", { link = "@field" })
vim.api.nvim_set_hl(0, "@lsp.typemod.property.static.cs", { bold = true, italic = true })
vim.api.nvim_set_hl(0, "@lsp.type.property.cs", { fg = "#ccdddd" })
vim.api.nvim_set_hl(0, "@lsp.type.namespace.cs", { fg = "#ccdddd" })
vim.api.nvim_set_hl(0, "@repeat.c_sharp", { link = "Conditional" })
vim.api.nvim_set_hl(0, "@type.builtin.c_sharp", { link = "@keyword" })
vim.api.nvim_set_hl(0, "@boolean_c_sharp", { link = "@keyword" })
vim.api.nvim_set_hl(0, "@storageclass.c_sharp", { link = "@keyword" })

local M = {}

---@type Base46HLGroupsList
M.override = {
    Comment = {
        italic = true,
        bold = true,
        fg = "#6a954c",
    },
}

M.override["@keyword"] = {
    -- Color = (86, 156, 214)
    fg = "#569cd6",
    bold = true,
}

-- Set telescope git status line removals to red and additions to green
M.override["TelescopeResultsDiffAdd"] = {
    fg = "#00ff00",
}

M.override["Repeat"] = {
    -- Typical purple color
    fg = "#c586c0",
}

M.override["@parameter"] = {
    fg = "#9cdcf0",
    bold = true,
}

M.override["TelescopeResultsDiffDelete"] = {
    fg = "#ff0000",
}

M.override["TelescopeResultsDiffChange"] = {
    fg = "#ffff00",
}

M.override["NvimTreeModifiedFile"] = {
    fg = "#feab48",
}

M.override.Typedef = {
    -- Color = (86, 156, 214)
    fg = "#4ec9b0",
    bold = true,
}

M.override["@punctuation.bracket"] = {
    -- Color = (255, 225, 0)
    fg = "#ffe100",
}

M.override.Delimiter = {
    fg = "#ffe100",
}

M.override["@punctuation.delimiter"] = {
    -- Color = (255, 225, 0)
    fg = "white",
    bold = true,
}
M.override["@punctuation.special"] = {
    -- Color = (255, 225, 0)
    fg = "#feab48",
    bold = true,
}

M.override["@constant"] = {
    bold = true,
    italic = true,
    fg = "#569cd6",
}

M.override.Label = {
    bold = true,
    fg = "#569cd6",
}

M.override.Number = {
    fg = "#b5cea8",
}

local F = {
    fg = "#dcd38b",
    bold = true,
}

M.override.Include = {
    -- Color = (197,134,192)
    fg = "#c586c0",
    bold = true,
}
M.override["@function"] = F
M.override["@function.call"] = F
M.override["@function.macro"] = F
M.override["@function.builtin"] = F
M.override.Function = F
M.override["@method"] = F
M.override["@lsp.type.method"] = F
M.override["@lsp.type.function"] = F
M.override["@method.call"] = F
M.override["@lsp.type.function.call"] = F
M.override["@lsp.type.function.builtin"] = F
M.override["@keyword.function"] = {
    fg = "teal",
}
M.override["@keyword.operator"] = {
    -- Color = (86, 156, 214)
    fg = "#569cd6",
}
M.override.Identifier = {
    fg = "#9cdcf0",
}
M.override["@field.key"] = {
    fg = "teal",
}
M.override["@namespace"] = {
    fg = "green",
}
M.override["@property"] = {
    -- Color: (156, 220, 240)
    fg = "#9cdcf0",
}

M.override["@field"] = {
    -- Color: (156, 220, 240)
    fg = "#9cdcf0",
}

M.override["@field.key"] = { fg = "red" }

M.override["@constructor"] = {
    -- Dark blue
    fg = "#365cd6",
}
M.override["@variable.builtin"] = {
    -- Dark blue
    fg = "#365cd6",
}

-- Variables are red: 79, green: 193, blue: 255
M.override["@variable"] = {
    fg = "#4fc1ff",
    bold = true,
}

-- red: 78, green: 201, blue: 176 in hex is: 4ec9b0
M.override["@type"] = {
    fg = "#4ec9b0",
    bold = true,
}
M.override.Type = {
    fg = "#4ec9b0",
    bold = true,
}

M.override.IndentBlanklineContextStart = {
    bold = true,
    -- Background color: (30,34,42)
    bg = "#342832",
    blend = 10,
}

local STR = {
    -- Color: (206, 145,120) in hex is: ce9178
    fg = "#ce9178",
    bold = true,
}
M.override["@string"] = STR
M.override.String = STR
---@type HLTable
M.add = {
    NvimTreeOpenedFolderName = { fg = "green", bold = true },
    -- Set keywords blue
}

return M
