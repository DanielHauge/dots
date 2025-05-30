local M = {}
M.override = {}

-- Debug highlight groups
vim.api.nvim_set_hl(0, "DapBreakpoint", { ctermbg = 0, bg = "#31353f" })
M.override.DapBreakpoint = { ctermbg = 0, bg = "#31353f" }
vim.api.nvim_set_hl(0, "DapLogPoint", { ctermbg = 0, bg = "#31353f" })
M.override.DapLogPoint = { ctermbg = 0, bg = "#31353f" }
vim.api.nvim_set_hl(0, "DapStopped", { ctermbg = 0, bg = "#31653f" })
M.override.DapStopped = { ctermbg = 0, bg = "#31653f" }
vim.fn.sign_define(
  "DapBreakpoint",
  { text = "🛑", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
)
vim.fn.sign_define("DapStopped", { text = "🟢", texthl = "DapStopped", linehl = "DapStopped", numhl = "DapStopped" })
vim.fn.sign_define(
  "DapLogPoint",
  { text = "📝", texthl = "DapLogPoint", linehl = "DapLogPoint", numhl = "DapLogPoint" }
)
vim.fn.sign_define("DapBreakpointRejected", { text = "🚫", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointConditional", { text = "🔍", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointDisabled", { text = "🔕", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointUnverified", { text = "🔍", texthl = "", linehl = "", numhl = "" })

-- Override custom nvim-treesitter highlight group links
-- TYPESCRIPT overrides
vim.api.nvim_set_hl(0, "@type.qualifier.typescript", { link = "@keyword" })
M.override["@type.qualifier.typescript"] = { link = "@keyword" }
vim.api.nvim_set_hl(0, "@lsp.type.class.typescript", { link = "Type" })
M.override["@lsp.type.class.typescript"] = { link = "Type" }
vim.api.nvim_set_hl(0, "@lsp.type.interface.typescript", { link = "Interface" })
M.override["@lsp.type.interface.typescript"] = { link = "Interface" }
vim.api.nvim_set_hl(0, "@lsp.type.enum.typescript", { fg = "#d25505" })
M.override["@lsp.type.enum.typescript"] = { fg = "#d25505" }

M.override["@lsp.type.variable"] = {

  fg = "#7fd1ff",
  bold = true,
}
-- C# Overrides

vim.api.nvim_set_hl(0, "@lsp.type.class.cs", { link = "@type" })
M.override["@lsp.type.class.cs"] = { link = "@type" }
vim.api.nvim_set_hl(0, "@lsp.type.keyword.cs", { link = "@keyword" })
M.override["@lsp.type.keyword.cs"] = { link = "@keyword" }
vim.api.nvim_set_hl(0, "@lsp.type.interface.cs", { link = "Interface" })
M.override["@lsp.type.interface.cs"] = { link = "Interface" }
vim.api.nvim_set_hl(0, "@lsp.type.parameter.cs", { link = "@field" })
M.override["@lsp.type.parameter.cs"] = { link = "@field" }
vim.api.nvim_set_hl(0, "@lsp.typemod.property.static.cs", { bold = true, italic = true })
M.override["@lsp.typemod.property.static.cs"] = { bold = true, italic = true }
vim.api.nvim_set_hl(0, "@lsp.type.property.cs", { fg = "#ccdddd" })
M.override["@lsp.type.property.cs"] = { fg = "#ccdddd" }
vim.api.nvim_set_hl(0, "@lsp.type.namespace.cs", { fg = "#ccdddd" })
M.override["@lsp.type.namespace.cs"] = { fg = "#ccdddd" }
vim.api.nvim_set_hl(0, "@repeat.c_sharp", { link = "Conditional" })
M.override["@repeat.c_sharp"] = { link = "Conditional" }
vim.api.nvim_set_hl(0, "@type.builtin.c_sharp", { link = "@keyword" })
M.override["@type.builtin.c_sharp"] = { link = "@keyword" }
vim.api.nvim_set_hl(0, "@boolean_c_sharp", { link = "@keyword" })
vim.api.nvim_set_hl(0, "@storageclass.c_sharp", { link = "@keyword" })
M.override["@storageclass.c_sharp"] = { link = "@keyword" }
vim.api.nvim_set_hl(0, "@lsp.type.event.cs", { fg = "#dcd38b", bold = true, italic = true })
M.override["@lsp.type.event.cs"] = { fg = "#dcd38b", bold = true, italic = true }
vim.api.nvim_set_hl(0, "@lsp.type.struct.cs", { fg = "#b5cea8" })
M.override["@lsp.type.struct.cs"] = { fg = "#b5cea8" }

-- Rust Overrides
M.override["@lsp.type.enum"] = { fg = "#5ea960" }
M.override["@lsp.type.enumMember.rust"] = { fg = "#46e666" }

vim.api.nvim_set_hl(0, "@variable.parameter.rust", { link = "@field" })
M.override["@variable.parameter.rust"] = { link = "@field" }
vim.api.nvim_set_hl(0, "@lsp.type.struct.rust", { link = "Type" })
M.override["@lsp.type.struct.rust"] = { link = "Type" }
M.override["@lsp.type.parameter"] = { fg = "#7fd1ff", bold = true }
vim.api.nvim_set_hl(0, "@lsp.type.interface.rust", { link = "Interface" })
M.override["@lsp.type.interface.rust"] = { link = "Interface" }

-- F# Overrides
vim.api.nvim_set_hl(0, "@lsp.type.namespace.fsharp", { fg = "#ccdddd" })
M.override["@lsp.type.namespace"] = { fg = "#ccdddd" }
vim.api.nvim_set_hl(0, "@keyword.function.fsharp", { link = "@keyword" })
M.override["@keyword.function.fsharp"] = { link = "@keyword" }

-- Yaml Overides
vim.api.nvim_set_hl(0, "yamlBlockMappingKey", { link = "Label" })
vim.api.nvim_set_hl(0, "yamlPlainScalar", { fg = "#cea168" })
M.override["yamlPlainScalar"] = { fg = "#cea168" }

-- C overrides
vim.api.nvim_set_hl(0, "@type.builtin.c", { fg = "#468cff", bold = true, italic = true })
M.override["@type.builtin.c"] = { fg = "#468cff", bold = true, italic = true }
vim.api.nvim_set_hl(0, "@lsp.type.class.c", { link = "Type" })
M.override["@lsp.type.class.c"] = { link = "Type" }

-- C++ overrides
vim.api.nvim_set_hl(0, "@lsp.type.class.cpp", { link = "Type" })
M.override["@lsp.type.class.cpp"] = { link = "Type" }
vim.api.nvim_set_hl(0, "@type.builtin.cpp", { fg = "#468cff", bold = true, italic = true })
M.override["@type.builtin.cpp"] = { fg = "#468cff", bold = true, italic = true }
vim.api.nvim_set_hl(0, "@lsp.type.parameter.cpp", { link = "@variable" })
M.override["@lsp.type.parameter.cpp"] = { link = "@variable" }
vim.api.nvim_set_hl(0, "@lsp.type.enum.cpp", { fg = "#5ea960" })
M.override["@lsp.type.enum.cpp"] = { fg = "#5ea960" }
vim.api.nvim_set_hl(0, "@lsp.type.enumMember.cpp", { fg = "#46e666" })
M.override["@lsp.type.enumMember.cpp"] = { fg = "#46e666" }

-- Ros2 overrides
vim.api.nvim_set_hl(0, "@variable.member.ros2", { link = "@variable" })
M.override["@variable.member.ros2"] = { link = "@variable" }

-- Java overrides
vim.api.nvim_set_hl(0, "@lsp.type.class.java", { link = "Type" })
M.override["@lsp.type.class.java"] = { link = "Type" }
vim.api.nvim_set_hl(0, "@lsp.type.interface.java", { link = "Interface" })
M.override["@lsp.type.interface.java"] = { link = "Interface" }
vim.api.nvim_set_hl(0, "@lsp.type.enum.java", { fg = "#d25505" })
M.override["@lsp.type.enum.java"] = { fg = "#d25505" }
vim.api.nvim_set_hl(0, "@type.qualifier.java", { link = "@keyword" })
M.override["@type.qualifier.java"] = { link = "@keyword" }
vim.api.nvim_set_hl(0, "@lsp.type.parameter.java", { link = "@field" })
M.override["@lsp.type.parameter.java"] = { link = "@field" }
vim.api.nvim_set_hl(0, "@type.builtin.java", { fg = "#468cff", bold = true, italic = true })
M.override["@type.builtin.java"] = { fg = "#468cff", bold = true, italic = true }

-- F# overrides
vim.api.nvim_set_hl(0, "@lsp.type.struct.fsharp", { fg = "#b5cea8" })
M.override["@lsp.type.struct.fsharp"] = { fg = "#b5cea8" }
vim.api.nvim_set_hl(0, "@lsp.type.typeParameter.fsharp", { link = "Interface" })
M.override["@lsp.type.typeParameter.fsharp"] = { link = "Interface" }
vim.api.nvim_set_hl(0, "@lsp.type.enumMember.fsharp", { link = "Interface" })
M.override["@lsp.type.enumMember.fsharp"] = { link = "Interface" }
vim.api.nvim_set_hl(0, "fsharpFunDef", { fg = "#dede5b" })
M.override["fsharpFunDef"] = { fg = "#dede5b" }
vim.api.nvim_set_hl(0, "@lsp.type.interface.fsharp", { link = "Interface" })
M.override["@lsp.type.interface.fsharp"] = { link = "Interface" }

-- Dart overrides
vim.api.nvim_set_hl(0, "@lsp.type.class.dart", { link = "Type" })
M.override["@lsp.type.class.dart"] = { link = "Type" }

M.override["@keyword"] = {
  -- Color = (86, 156, 214)
  fg = "#569cd6",
  bold = true,
}

M.override["@lsp.type.keyword"] = {
  -- Color = (86, 156, 214)
  fg = "#569cd6",
}

-- Set telescope git status line removals to red and additions to green
M.override["TelescopeResultsDiffAdd"] = {
  fg = "#00ff00",
}

M.override["Repeat"] = {
  -- Typical purple color
  fg = "#c586c0",
}

M.override["@keyword.conditional"] = M.override["Conditional"]
M.override["@keyword.function"] = {
  -- Color = (86, 156, 214)
  fg = "#569cd6",
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
vim.api.nvim_set_hl(0, "DiagnosticUnnecessary", {
  strikethrough = true,
  fg = "#6a954c",
})

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
M.override["@number"] = {
  fg = "#b5cea8",
}

local F = {
  fg = "#dcd38b",
  bold = true,
}
local FBuiltin = {
  fg = "#fce35b",
  bold = true,
}

M.override.Include = {
  -- Color = (197,134,192)
  fg = "#c586c0",
  bold = true,
}
M.override["@lsp.typemod.function.defaultLibrary"] = F
M.override["@lsp.typemod.method.defaultLibrary "] = F
M.override["@lsp.typemod.function.defaultLibrary.rust"] = F
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
M.override["@lsp.type.macro"] = FBuiltin

M.override["@module"] = {
  fg = "#ccdddd",
}

M.override["@keyword.operator"] = {
  -- Color = (86, 156, 214)
  fg = "#569cd6",
}

M.override["@keyword.return"] = {
  -- Color = (86, 156, 214)
  fg = "#569cd6",
}

M.override["@keyword.repeat"] = {
  -- Color = (86, 156, 214)
  fg = "#569cd6",
}
M.override["@keyword.conditional"] = {
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
  fg = "#ccdddd",
}

M.override["@lsp.type.property"] = {
  fg = "#9cdcf0",
}
M.override["@property"] = {
  -- Color: (156, 220, 240)
  fg = "#9cdcf0",
}

M.override["@lsp.type.field"] = {

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
  fg = "#7fd1ff",
  bold = true,
}
M.override["@variable.member"] = {
  fg = "#4fc1df",
  bold = true,
}
-- @keyword.directive -> ORANGE
M.override["@keyword.directive"] = {
  fg = "#feab48",
  bold = true,
}

M.override["@variable.parameter"] = {
  fg = "#7fd1ff",
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
M.add = {
  NvimTreeOpenedFolderName = { fg = "green", bold = true },
  Interface = {
    fg = "#aef9b0",
  },
  -- Set keywords blue
}
vim.api.nvim_set_hl(0, "Interface", { fg = "#aef9b0" })
M.override["@lsp.type.interface"] = { fg = "#aef9b0" }
M.override.Interface = { fg = "#aef9b0" }
-- Greenish, but more warm and yellow, more greener, hakcerlike
M.override["Special"] = { fg = "#aef9b0" }

return M.override
