return {
  -- Treesitter for syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    opts = {
      ensure_installed = { 
        "lua", "python", "bash", "query", "vim", "vimdoc", 
        "json", "yaml", "toml", "ini", "dockerfile", "tmux", "make",
        "markdown", "markdown_inline"
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      local status_ok, configs = pcall(require, "nvim-treesitter.configs")
      if status_ok then
        configs.setup(opts)
      end
    end,
  },

  -- Gitsigns for git integration
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- Gemini integration via Snacks.terminal (persistent and conflict-free)
  {
    "folke/snacks.nvim",
    opts = {
      styles = {
        terminal = {
          wo = {
            winbar = "",
          },
        },
      },
      terminal = {
        enabled = true,
      },
    },
    keys = {},
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  -- Comments
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  -- Trouble
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },
  -- mini.surround - Surround operations
  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    opts = {
      mappings = {
        add = "gsa",
        delete = "gsd",
        find = "gsf",
        find_left = "gsF",
        highlight = "gsh",
        replace = "gsr",
        update_n_lines = "gsn",
      },
    },
  },
  -- flash.nvim - Fast motion/jumping
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
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
  -- OpenCode AI Integration (Integrated UI)
  {
    "nickjvandyke/opencode.nvim",
    version = "*",
    dependencies = { "folke/snacks.nvim" },
    config = function()
      -- vim.g.opencode_opts = {}
      vim.o.autoread = true -- Required for opts.events.reload

      -- Integrated keymaps
      vim.keymap.set({ "n", "x" }, "<C-a>", function()
        require("opencode").ask("@this: ", { submit = true })
      end, { desc = "Ask opencode…" })
      
      vim.keymap.set({ "n", "x" }, "<C-x>", function()
        require("opencode").select()
      end, { desc = "Execute opencode action…" })
      
      vim.keymap.set({ "n", "t" }, "<C-.>", function()
        Snacks.terminal.toggle("opencode", {
          win = { position = "right" }
        })
      end, { desc = "Toggle opencode" })
    end,
  },
}
