local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
augroup("highlight_yank", { clear = true })
autocmd("TextYankPost", {
  group = "highlight_yank",
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Go to last loc when opening a buffer
autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

  -- Transparency: Force inheritance of terminal background
local function transparent_bg()
  local groups = {
    "Normal", "NormalFloat", "SignColumn", "EndOfBuffer", "MsgArea",
    "SnacksDashboardNormal", "SnacksPickerNormal", "SnacksPickerList"
  }
  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
  end
end

autocmd({ "ColorScheme", "VimEnter" }, {
  callback = transparent_bg,
})

-- Disable line numbers and filler lines for specific filetypes
autocmd({ "FileType", "BufEnter" }, {
  pattern = { "lazy", "mason", "snacks_dashboard", "snacks_terminal" },
  callback = function()
    if vim.tbl_contains({ "lazy", "mason", "snacks_dashboard", "snacks_terminal" }, vim.bo.filetype) then
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
      vim.opt_local.fillchars = "eob: "
      if vim.bo.filetype == "snacks_dashboard" then
        vim.keymap.set("n", "q", "<nop>", { buffer = true, nowait = true })
      end
    end
  end,
})

-- Watch filesystem for changes and check for external file changes
local function setup_file_watch()
  local function do_refresh()
    vim.schedule(function()
      vim.cmd("checktime")
    end)
  end

  if vim.fs.watch then
    local cwd = vim.fn.getcwd()
    local watcher = vim.fs.watch(cwd, function(events)
      do_refresh()
    end)
    if not watcher then
      print("Failed to start filesystem watcher")
    end
  else
    local timer = vim.uv.new_timer()
    if timer then
      vim.uv.timer_start(timer, 2000, 2000, do_refresh)
    end
  end
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = setup_file_watch,
})

