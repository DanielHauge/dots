local options = {
    filters = {
        dotfiles = false,
        exclude = { vim.fn.stdpath "config" .. "/lua/custom" },
        custom = { ".null-ls.*" },
    },
    disable_netrw = true,
    hijack_netrw = true,
    hijack_cursor = true,
    hijack_unnamed_buffer_when_opening = false,
    sync_root_with_cwd = false,
    update_focused_file = {
        enable = true,
        update_root = false,
    },
    view = {
        adaptive_size = true,
        preserve_window_proportions = true,
        -- side = "float",
        -- width = 25,

        float = {
            enable = true,
            -- Middle
            open_win_config = function()
                local width = vim.api.nvim_get_option "columns"
                local height = vim.api.nvim_get_option "lines"
                return {
                    width = math.min(width - 10, 100),
                    height = math.min(height - 4, 30),
                    relative = "editor",
                    row = 2,
                    col = math.floor((width - 100) / 2),
                    border = "rounded",
                }
            end,
        },
        width = 70,
    },
    filesystem_watchers = {
        enable = true,
    },
    actions = {
        open_file = {
            resize_window = true,
        },
    },
    modified = {
        enable = true,
    },
    diagnostics = {
        enable = true,
        show_on_dirs = true,
    },
    renderer = {
        root_folder_label = false,
        group_empty = false,
        highlight_git = false,

        highlight_modified = "all",
        indent_markers = {
            enable = true,
        },
        icons = {
            show = {
                file = true,
                folder = true,
                folder_arrow = true,
                git = true,
            },

            glyphs = {
                default = "󰈚",
                symlink = "",
                folder = {
                    default = "",
                    empty = "",
                    empty_open = " ",
                    open = "",
                    symlink = "",
                    symlink_open = "",
                    arrow_open = "",
                    arrow_closed = "",
                },
                git = {
                    unstaged = "✗",
                    staged = "✓",
                    unmerged = "",
                    renamed = "➜",
                    untracked = "★",
                    deleted = "",
                    ignored = "◌",
                },
            },
        },
    },
}

return options
