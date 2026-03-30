return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- delay before the popup shows up
    delay = 300,
    icons = {
      breadcrumb = "»",
      separator = "➜",
      group = "+",
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    
    -- Register group names
    wk.add({
      { "<leader>f", group = "find" },
      { "<leader>t", group = "terminal" },
      { "<leader>w", group = "window" },
      { "<leader>c", group = "code" },
      { "<leader>b", group = "buffer" },
      { "<leader>g", group = "git" },
      { "<leader>s", group = "search" },
      { "<leader>x", group = "diagnostics" },
      { "gs", group = "surround" },
      { "[", group = "prev" },
      { "]", group = "next" },
    })
  end,
}