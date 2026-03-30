return {
  {
    "echasnovski/mini.nvim",
    version = false,
    config = function()
      -- 1. Surround: handles parentheses, quotes, etc.
      require("mini.surround").setup({
        mappings = {
          add = "gsa",
          delete = "gsd",
          find = "gsf",
          find_left = "gsF",
          highlight = "gsh",
          replace = "gsr",
          update_n_lines = "gsn",
        },
      })

      -- 2. Hipatterns: highlights hex colors and more
      local hipatterns = require("mini.hipatterns")
      hipatterns.setup({
        highlighters = {
          hex_color = hipatterns.gen_highlighter.hex_color(),
        },
      })

      -- 3. Icons: fast and lightweight icon provider
      local mini_icons = require("mini.icons")
      mini_icons.setup()
      mini_icons.mock_nvim_web_devicons()

      -- 4. Pairs: autopairs for consistent editing
      require("mini.pairs").setup({})
    end,
  },
}
