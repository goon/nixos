return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        -- Event handlers to ensure window local options are always applied
        event_handlers = {
          {
            event = "neo_tree_buffer_enter",
            handler = function()
              vim.opt_local.fillchars = { eob = " " }
            end,
          },
        },
        window = {
          width = 36,
          mappings = {
            ["<space>"] = "none",
            ["h"] = "close_node",
            ["l"] = "open",
            ["C"] = function(state)
              local node = state.tree:get_node()
              if node.type == 'directory' then
                vim.api.nvim_set_current_dir(node.path)
                print("CWD changed to: " .. node.path)
              else
                vim.api.nvim_set_current_dir(node:get_parent_id())
                print("CWD changed to: " .. node:get_parent_id())
              end
            end,
          },
        },
        filesystem = {
          filtered_items = {
            visible = true, -- This shows hidden files by default
            hide_dotfiles = false,
            hide_gitignored = false,
          },
        },
        default_component_configs = {
          indent = {
            with_markers = true,
            indent_marker = "│",
            last_indent_marker = "└",
            indent_size = 2,
            padding = 1,
          },
          git_status = {
            symbols = {
              added     = "A",
              modified  = "M",
              deleted   = "D",
              renamed   = "R",
              untracked = "?",
              ignored   = "I",
              unstaged  = "U",
              staged    = "S",
              conflict  = "C",
            },
          },
        },
      })
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local colors = require("nvim")
      local bridge = require("theme")

      require("lualine").setup({
        options = {
          theme = bridge.get_lualine_theme(colors),
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
      })
    end,
  },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local colors = require("nvim")
      local bridge = require("theme")

      require("bufferline").setup({
        options = {
          mode = "buffers",
          separator_style = "slope",
          always_show_bufferline = true,
          show_buffer_close_icons = false,
          show_close_icon = false,
          color_icons = false,
          show_buffer_icons = false,
          offsets = {
            {
              filetype = "neo-tree",
              text = "",
              text_align = "center",
              separator = false,
            },
          },
          filter = function(buf)
            local buftype = vim.bo[buf].buftype
            -- Only show normal file buffers (skip special buffers like AI tools, terminals, etc.)
            return buftype == ''
          end,
        },
        highlights = bridge.get_bufferline_highlights(colors),
      })
    end,
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      dashboard = {
        enabled = true,
        preset = {
          header = [[
                                                                       
                                                                     
       ████ ██████           █████      ██                     
      ███████████             █████                             
      █████████ ███████████████████ ███   ███████████   
     █████████  ███    █████████████ █████ ██████████████   
    █████████ ██████████ █████████ █████ █████ ████ █████   
  ███████████ ███    ███ █████████ █████ █████ ████ █████  
 ██████  █████████████████████ ████ █████ █████ ████ ██████ 
                                                                       ]],
        },
        sections = {
          { section = "header" },
          {
            section = "keys",
            gap = 1,
            padding = 1,
            items = {
              { icon = " ", key = "n", desc = "New file", action = ":ene | startinsert" },
              { icon = " ", key = "r", desc = "Recent files", action = ":Snacks.picker.recent()" },
              { icon = " ", key = "g", desc = "Find text", action = ":Snacks.picker.grep()" },
              { icon = " ", key = "c", desc = "Config", action = ":e $MYVIMRC" },
              { icon = " ", key = "q", desc = "Quit", action = ":qa" },
            },
          },
          { section = "startup" },
        },
      },
      notifier = { enabled = true },
      indent = { enabled = true },
      scroll = { enabled = true },
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      terminal = { enabled = true },
      input = { enabled = true },
      picker = {
        enabled = true,
        actions = {
          opencode_send = function(...)
            return require("opencode").snacks_picker_send(...)
          end,
        },
        win = {
          input = {
            keys = {
              ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
            },
          },
        },
      },
      lazygit = { enabled = true },
    },
  },
  {
    "NvChad/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({
        user_default_options = {
          names = false,       -- "Name" codes like Blue or Red
          RRGGBBAA = true,     -- #RRGGBBAA hex codes
          AARRGGBB = false,    -- 0xAARRGGBB hex codes
          rgb_fn = true,       -- CSS rgb() and rgba() functions
          hsl_fn = true,       -- CSS hsl() and hsla() functions
          css = true,          -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
          css_fn = true,       -- Enable all CSS *functions*: rgb_fn, hsl_fn
          -- Available modes for `mode`: foreground, background,  virtualtext
          mode = "background", -- Set the display mode.
          tailwin = true,      -- Enable tailwind colors
        },
      })
    end,
  },
}
