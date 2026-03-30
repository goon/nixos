return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    dashboard = {
      enabled = true,
      formats = {
        icon = function()
          return { "", width = 0 }
        end,
      },
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
        keys = {
          { key = "f", desc = "Find File",       action = function() Snacks.picker.files() end },
          { key = "n", desc = "New File",        action = ":ene | startinsert" },
          { key = "g", desc = "Find Text",       action = function() Snacks.picker.grep() end },
          { key = "r", desc = "Recent Files",    action = function() Snacks.picker.recent() end },
          { key = "c", desc = "Config",          action = ":e $MYVIMRC" },
          { key = "l", desc = "Lazy",            action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { key = "q", desc = "Quit",            action = function() end, hidden = true },
        },
      },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
      },
    },
    notifier = { enabled = true },
    indent = { enabled = true },
    scroll = { enabled = true },
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    styles = {
      terminal = {
        wo = {
          winbar = "",
        },
      },
    },
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
}
