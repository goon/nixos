local map = vim.keymap.set

-- Paste from system clipboard in insert mode
map("i", "<C-v>", '<C-r>+', { desc = "Paste from system clipboard" })



-- Snacks Picker (Fuzzy Finder replacements)
map("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Find Files" })
map("n", "<leader>fg", function() Snacks.picker.grep() end, { desc = "Live Grep" })
map("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "Find Buffers" })
map("n", "<leader>fh", function() Snacks.picker.help() end, { desc = "Find Help" })
map("n", "<leader>fs", function() Snacks.picker.smart() end, { desc = "Smart Find Files" })
map("n", "<leader>fw", function() Snacks.picker.grep_word() end, { desc = "Search Word" })


map({ "n", "t" }, "<A-[>", "<cmd>bprevious<cr>", { desc = "Previous Buffer" })
map({ "n", "t" }, "<A-]>", "<cmd>bnext<cr>",     { desc = "Next Buffer" })

-- Terminal (Snacks Terminal)
map("n", "<leader>th", function() Snacks.terminal.toggle(nil, { win = { position = "bottom" } }) end, { desc = "Toggle Horizontal Terminal" })
map("n", "<leader>tv", function() Snacks.terminal.toggle(nil, { win = { position = "right" } }) end, { desc = "Toggle Vertical Terminal" })

 -- Window Navigation
 map({ "n", "t" }, "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Go to Left Window" })
 map({ "n", "t" }, "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Go to Lower Window" })
 map({ "n", "t" }, "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Go to Upper Window" })
 map({ "n", "t" }, "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Go to Right Window" })

 -- Window Management
 map("n", "<leader>v", "<C-w>v", { desc = "Vertical Split" })
 map("n", "<leader>h", "<C-w>s", { desc = "Horizontal Split" })
 map("n", "<leader>cw", "<C-w>c", { desc = "Close Window" })
 map("n", "<A-j>", "<C-w>J", { desc = "Move Window Down" })
 map("n", "<A-k>", "<C-w>K", { desc = "Move Window Up" })
 map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
 map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
 map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
 map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })




 -- Buffer Management
 map("n", "[b", ":bprevious<cr>", { desc = "Previous Buffer" })
 map("n", "]b", ":bnext<cr>", { desc = "Next Buffer" })
 map("n", "<Tab>", ":bnext<cr>", { desc = "Next Buffer" })
 map("n", "<S-Tab>", ":bprevious<cr>", { desc = "Previous Buffer" })
 map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
 map("n", "<leader>bd", ":bdelete<cr>", { desc = "Delete Buffer" })

 map("n", "<leader>bo", "<cmd>%bd|e#|bd#<cr>", { desc = "Delete Other Buffers" })
 map("n", "<leader>bf", function() require("conform").format({ async = true, lsp_fallback = true }) end, { desc = "Format Buffer" })

  -- General/Misc
  map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })
  map("n", "<leader>q", "<cmd>qa<cr>", { desc = "Quit All" })
  map("n", "<leader>wq", "<cmd>wqa<cr>", { desc = "Save and Quit All" })
  
  map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })
  map("n", "<esc>", "<cmd>nohlsearch<cr>", { desc = "Clear hlsearch in Normal mode" })

  -- Save All Files
  map("n", "<leader>s", "<cmd>wa<cr>", { desc = "Save All Files" })

  -- Git
  map("n", "<leader>gg", function() Snacks.lazygit.open() end, { desc = "Open LazyGit" })
  map("n", "<leader>gb", function() Snacks.picker.git_branches() end, { desc = "Git Branches" })
  map("n", "<leader>gs", function() Snacks.picker.git_status() end, { desc = "Git Status" })

  -- Diagnostics Navigation
  map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next Diagnostic" })
  map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Prev Diagnostic" })
  map("n", "]e", function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = true }) end, { desc = "Next Error" })
  map("n", "[e", function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = true }) end, { desc = "Prev Error" })
  map("n", "<leader>cd", function() vim.diagnostic.open_float() end, { desc = "Line Diagnostics" })
  map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })

  -- Toggle indent guides
  map("n", "<leader>ti", function() Snacks.toggle.indent():toggle() end, { desc = "Toggle Indent Guides" })

