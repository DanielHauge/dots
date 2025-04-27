return {
  "onsails/lspkind.nvim",
  config = function()
    require("lspkind").setup({
      formatting = {
        fields = { "kind", "abbr", "menu" },

        format = function(entry, vim_item)
          local kind = require("lspkind").cmp_format({
            mode = "symbol_text",
          })(entry, vim.deepcopy(vim_item))
          local highlights_info = require("colorful-menu").cmp_highlights(entry)

          -- highlight_info is nil means we are missing the ts parser, it's
          -- better to fallback to use default `vim_item.abbr`. What this plugin
          -- offers is two fields: `vim_item.abbr_hl_group` and `vim_item.abbr`.
          if highlights_info ~= nil then
            vim_item.abbr_hl_group = highlights_info.highlights
            vim_item.abbr = highlights_info.text
          end
          local strings = vim.split(kind.kind, "%s", { trimempty = true })
          vim_item.kind = " " .. (strings[1] or "") .. " "
          vim_item.menu = ""

          return vim_item
        end,
      },
    })
  end,
}
