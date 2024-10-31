-- Define the `daf` motion
vim.api.nvim_set_keymap("n", "daf", ":lua delete_around_function()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "dat", ":lua delete_around_type()<CR>", { noremap = true, silent = true })

function delete_around_function()
    local ts_utils = require "nvim-treesitter.ts_utils"
    local node = ts_utils.get_node_at_cursor()

    while node do
        if
            node:type() == "function_definition"
            or node:type() == "method_definition"
            or node:type() == "function_item"
            or node:type() == "method_declaration"
            or node:type() == "function_declaration"
        then
            local start_row, start_col, end_row, end_col = node:range()
            vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, {})
            return
        end
        node = node:parent()
    end
    print "No function found at cursor"
end

function delete_around_type()
    local ts_utils = require "nvim-treesitter.ts_utils"
    local node = ts_utils.get_node_at_cursor()

    while node do
        if
            node:type() == "class_declaration"
            or node:type() == "class_definition"
            or node:type() == "class_item"
            or node:type() == "type_declaration"
        then
            local start_row, start_col, end_row, end_col = node:range()
            vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, {})
            return
        end
        node = node:parent()
    end
    print "No type found at cursor"
end
