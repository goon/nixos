return {
  -- Comments
  {
    "numToStr/Comment.nvim",
    opts = {},
  },

  -- Trouble
  {
    "folke/trouble.nvim",
    opts = {},
  },

  -- flash.nvim - Fast motion/jumping
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Jump" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },

  -- yanky.nvim - Yank history
  {
    "gbprod/yanky.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "<leader>p", function() require("yanky.picker").show() end, desc = "Yank History" },
      { "[y", function() require("yanky").cycle(1) end, desc = "Prev Yank" },
      { "]y", function() require("yanky").cycle(-1) end, desc = "Next Yank" },
    },
  },

  -- grug-far.nvim - Project-wide search and replace
  {
    "MagicDuck/grug-far.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "<leader>sr", function() require("grug-far").open() end, desc = "Search and Replace" },
    },
  },
}
