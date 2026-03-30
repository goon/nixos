return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "echasnovski/mini.nvim" },
  config = function()
    local palette = require("config.palette")
    local colors = palette.get_colors()
    if not colors then return end

    local theme_mod = require("config.theme")

    require("lualine").setup({
      options = {
        theme = theme_mod.get_lualine_theme(colors),
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = {
          {
            function()
              return " " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
            end,
            color = "LualineCwd",
          },
          { "filename", path = 1 },
        },
        lualine_x = {
          function()
            local ft = vim.bo.filetype
            if ft == "" then return "" end
            return "." .. ft
          end,
        },
        lualine_y = {},
        lualine_z = {
          {
            function()
              local buffers = vim.fn.getbufinfo({ buflisted = 1 })
              return "(" .. #buffers .. ")"
            end,
            color = "LualineBuffers",
          },
          function()
            return string.format("%%p%%%%  %%c")
          end,
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          {
            function()
              return " " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
            end,
            color = "LualineCwdInactive",
          },
          { "filename", path = 1 },
        },
        lualine_x = {
          function()
            return string.format("%%p%%%%  %%c")
          end,
        },
        lualine_y = {},
        lualine_z = {},
      },
    })
  end,
}
