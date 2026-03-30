-- Add Quickshell cache to the Lua search path
package.path = vim.fn.expand("$HOME/.cache/quickshell/themes/?.lua;") .. package.path

-- 1. General Options & Keys (must be set before lazy.nvim)
require("config.options")
require("config.autocmds")

-- 2. Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- 3. Setup lazy.nvim (loads everything in lua/plugins/*.lua)
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  install = { colorscheme = { "habamax" } },
  checker = { enabled = true },
})

-- 4. Keymaps
require("config.keymaps")

-- 5. Integrated Theming Bridge (Quickshell)
require("config.theme").setup()
