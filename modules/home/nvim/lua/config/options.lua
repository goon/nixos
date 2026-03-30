-- Set leader keys (must be set before lazy.nvim)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Disable netrw (default file explorer)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Detailed Neovim Options Configuration

local opt = vim.opt

-- [[ UI Settings ]]
opt.number = true             -- Show line numbers
opt.relativenumber = true     -- Use relative line numbers (essential for vertical jumps)
opt.signcolumn = "yes"        -- Always show sign column (prevents text jumping when icons appear)
opt.cursorline = true         -- Highlight the current line
opt.termguicolors = true      -- Enable 24-bit RGB colors
opt.scrolloff = 10            -- Keep at least 10 lines above/below cursor when scrolling
opt.showmode = false          -- Don't show mode in command line (Lualine handles it)
opt.laststatus = 3            -- Global statusline (one statusline for all windows)
opt.fillchars = "eob: "       -- Hide ~ at the end of the buffer
opt.showtabline = 0           -- Completely hide tabline

-- [[ Indentation ]]
opt.expandtab = true          -- Convert tabs to spaces
opt.shiftwidth = 2            -- Number of spaces for each step of (auto)indent
opt.tabstop = 2               -- Number of spaces a tab counts for
opt.smartindent = true        -- Insert indents automatically
opt.softtabstop = 2           -- Number of spaces a tab counts for while editing

-- [[ Search ]]
opt.ignorecase = true         -- Ignore case in search patterns
opt.smartcase = true          -- Unless \C or a capital letter is used
opt.hlsearch = false          -- Don't keep results highlighted after search

-- [[ Performance & UX ]]
opt.mouse = "a"               -- Enable mouse support
opt.clipboard = "unnamedplus" -- Sync with system clipboard
opt.updatetime = 250          -- Faster completion and diagnostic display (default 4000)
opt.timeoutlen = 300          -- Time to wait for a mapped sequence to complete (ms)
opt.undofile = true           -- Save undo history to a file (survives restarts)
opt.swapfile = false          -- Disable swap files
opt.splitright = true         -- Put new windows to the right of current
opt.splitbelow = true         -- Put new windows below current
opt.wrap = false              -- Disable line wrapping

-- Enable line wrapping for markdown files only
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
  end,
})

opt.autoread = true           -- Automatically re-read files if changed outside Neovim
