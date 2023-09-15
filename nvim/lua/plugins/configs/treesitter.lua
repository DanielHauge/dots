local options = {
  ensure_installed = {
    "lua",
    "bash",
    "c",
    "comment",
    "css",
    "go",
    "graphql",
    "help",
    "html",
    "http",
    "json",
    "latex",
    "lua",
    "python",
    "c_sharp",
    "rust",
  },
  -- Set parser install dir
  highlight = {
    enable = true,
    use_languagetree = true,
  },
  sync_install = false,
  indent = { enable = true },
}

return options
