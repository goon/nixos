-- Set leader keys before lazy.nvim
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Add Quickshell cache to the Lua search path (takes priority for 'colors')
package.path = vim.fn.expand("$HOME/.cache/quickshell/themes/?.lua;") .. package.path

-- 1. General Options
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
vim.opt.termguicolors = true
local function apply_qs_theme()
	package.loaded["nvim"] = nil
	package.loaded["theme"] = nil
	local status, bridge = pcall(require, "theme")
	if status then
		bridge.apply()
	end
end

-- Setup signal listener for live reload (SIGUSR1)
local signal = vim.uv.new_signal()
if signal then
	vim.uv.signal_start(signal, "sigusr1", function()
		vim.schedule(function()
			apply_qs_theme()
			print("Theme reloaded")
		end)
	end)
end

-- Initial application
apply_qs_theme()
