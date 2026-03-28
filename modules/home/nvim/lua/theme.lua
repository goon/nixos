local M = {}

function M.apply()
  local status, c = pcall(require, "nvim")
  if not status then
    return
  end

  -- Semantic mappings from Base16 palette
  local colors = {
    -- Backgrounds (dark to light)
    background = c.base00,
    surface = c.base01,
    surfaceAlt = c.base02,
    -- Comments, muted elements
    muted = c.base03,
    -- Foregrounds (dark to light)
    textMuted = c.base04,
    text = c.base05,
    textDim = c.base06,
    textBright = c.base07,
    -- Accents
    error = c.base08,
    warning = c.base09,
    accent = c.base0A,
    success = c.base0B,
    info = c.base0C,
    primary = c[c.primaryIdx] or c.base0D,
    secondary = c[c.secondaryIdx] or c.base0E,
    brown = c.base0F,
    -- Borders
    border = c.base01,
    borderActive = c[c.primaryIdx] or c.base0D,
    outline = c.base02,
  }

  local hl = vim.api.nvim_set_hl

  -- 1. Base UI
  hl(0, "Normal", { fg = colors.text, bg = "NONE" })
  hl(0, "NormalFloat", { fg = colors.text, bg = "NONE" })
  hl(0, "FloatBorder", { fg = colors.borderActive, bg = "NONE" })
  hl(0, "CursorLine", { bg = "NONE" })
  hl(0, "CursorLineNr", { fg = colors.primary, bold = true })
  hl(0, "LineNr", { fg = colors.textMuted })
  hl(0, "Visual", { bg = colors.surfaceAlt })
  hl(0, "Search", { bg = colors.primary, fg = colors.background })
  hl(0, "IncSearch", { bg = colors.accent, fg = colors.background })
  hl(0, "MatchParen", { fg = colors.accent, bold = true, underline = true })
  hl(0, "WinSeparator", { fg = colors.border })
  hl(0, "StatusLine", { fg = colors.text, bg = "NONE" })
  hl(0, "StatusLineNC", { fg = colors.textMuted, bg = "NONE" })
  hl(0, "Pmenu", { fg = colors.text, bg = "NONE" })
  hl(0, "PmenuSel", { bg = colors.surfaceAlt, bold = true })

  -- 2. Syntax Highlighting
  hl(0, "Comment", { fg = colors.muted, italic = true })
  hl(0, "Constant", { fg = colors.secondary })
  hl(0, "String", { fg = colors.success })
  hl(0, "Character", { fg = colors.success })
  hl(0, "Number", { fg = colors.secondary })
  hl(0, "Boolean", { fg = colors.secondary, bold = true })
  hl(0, "Float", { fg = colors.secondary })

  hl(0, "Identifier", { fg = colors.text })
  hl(0, "Function", { fg = colors.primary, bold = true })

  hl(0, "Statement", { fg = colors.accent })
  hl(0, "Conditional", { fg = colors.accent, italic = true })
  hl(0, "Repeat", { fg = colors.accent })
  hl(0, "Label", { fg = colors.accent })
  hl(0, "Operator", { fg = colors.info })
  hl(0, "Keyword", { fg = colors.accent, italic = true })
  hl(0, "Exception", { fg = colors.error })

  hl(0, "PreProc", { fg = colors.accent })
  hl(0, "Include", { fg = colors.accent })
  hl(0, "Define", { fg = colors.accent })
  hl(0, "Macro", { fg = colors.accent })
  hl(0, "PreCondit", { fg = colors.accent })

  hl(0, "Type", { fg = colors.info })
  hl(0, "StorageClass", { fg = colors.info })
  hl(0, "Structure", { fg = colors.info })
  hl(0, "Typedef", { fg = colors.info })

  hl(0, "Special", { fg = colors.secondary })
  hl(0, "SpecialChar", { fg = colors.secondary })
  hl(0, "Tag", { fg = colors.accent })
  hl(0, "Delimiter", { fg = colors.textMuted })
  hl(0, "SpecialComment", { fg = colors.muted, italic = true })
  hl(0, "Debug", { fg = colors.warning })

  hl(0, "Underlined", { underline = true })
  hl(0, "Bold", { bold = true })
  hl(0, "Italic", { italic = true })
  hl(0, "Error", { fg = colors.error, bold = true })
  hl(0, "Todo", { fg = colors.warning, bold = true })

  -- 3. Diagnostics
  hl(0, "DiagnosticError", { fg = colors.error })
  hl(0, "DiagnosticWarn", { fg = colors.warning })
  hl(0, "DiagnosticInfo", { fg = colors.info })
  hl(0, "DiagnosticHint", { fg = colors.accent })
  hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = colors.error })
  hl(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = colors.warning })

  -- 4. Treesitter (Most common)
  hl(0, "@function", { link = "Function" })
  hl(0, "@method", { link = "Function" })
  hl(0, "@keyword", { link = "Keyword" })
  hl(0, "@variable", { fg = colors.text })
  hl(0, "@variable.builtin", { fg = colors.accent, italic = true })
  hl(0, "@property", { fg = colors.info })
  hl(0, "@field", { fg = colors.info })
  hl(0, "@type", { link = "Type" })
  hl(0, "@parameter", { fg = colors.text, italic = true })
  hl(0, "@string", { link = "String" })
  hl(0, "@constant", { link = "Constant" })
  hl(0, "@punctuation.bracket", { fg = colors.textDim })
  hl(0, "@punctuation.delimiter", { fg = colors.textDim })

  -- 5. Plugin Specifics
  -- NeoTree
  hl(0, "NeoTreeNormal", { fg = colors.text, bg = "NONE" })
  hl(0, "NeoTreeNormalNC", { fg = colors.text, bg = "NONE" })
  hl(0, "NeoTreeDirectoryName", { fg = colors.primary })
  hl(0, "NeoTreeDirectoryIcon", { fg = colors.primary })
  hl(0, "NeoTreeFolderName", { fg = colors.primary })
  hl(0, "NeoTreeRootName", { fg = colors.primary, bold = true })
  hl(0, "NeoTreeFileName", { fg = colors.text })
  hl(0, "NeoTreeFileIcon", { fg = colors.text })
  hl(0, "NeoTreeSymbolicLinkTarget", { fg = colors.accent })
  hl(0, "NeoTreeIndentMarker", { fg = colors.outline })
  hl(0, "NeoTreeExpander", { fg = colors.textMuted })
  hl(0, "NeoTreeWinSeparator", { fg = colors.border, bg = "NONE" })

  -- NeoTree Git
  hl(0, "NeoTreeGitAdded", { fg = colors.success })
  hl(0, "NeoTreeGitConflict", { fg = colors.error, bold = true })
  hl(0, "NeoTreeGitDeleted", { fg = colors.error })
  hl(0, "NeoTreeGitIgnored", { fg = colors.muted })
  hl(0, "NeoTreeGitModified", { fg = colors.warning })
  hl(0, "NeoTreeGitUnstaged", { fg = colors.secondary })
  hl(0, "NeoTreeGitUntracked", { fg = colors.accent })
  hl(0, "NeoTreeGitStaged", { fg = colors.success })

  -- Gitsigns
  hl(0, "GitSignsAdd", { fg = colors.success, bg = "NONE" })
  hl(0, "GitSignsChange", { fg = colors.warning, bg = "NONE" })
  hl(0, "GitSignsDelete", { fg = colors.error, bg = "NONE" })
  hl(0, "GitSignsAddLn", { bg = colors.success, fg = colors.background })
  hl(0, "GitSignsChangeLn", { bg = colors.warning, fg = colors.background })
  hl(0, "GitSignsDeleteLn", { bg = colors.error, fg = colors.background })

  -- Snacks Picker
  hl(0, "SnacksPickerListCursorLine", { bg = "NONE" })
  hl(0, "SnacksPickerSelected", { fg = colors.accent, bold = true })
  hl(0, "SnacksPickerCaret", { fg = colors.accent, bold = true })
  hl(0, "SnacksPickerMatch", { fg = colors.primary, bold = true })
  hl(0, "SnacksPickerBorder", { fg = colors.borderActive })
  hl(0, "SnacksPickerPromptBorder", { fg = colors.primary })
  hl(0, "SnacksPickerInput", { fg = colors.text })

  -- Indent Blankline
  hl(0, "IblIndent", { fg = colors.surface, nocombine = true })
  hl(0, "IblScope", { fg = colors.muted, nocombine = true })
  hl(0, "IblWhitespace", { fg = colors.surface, nocombine = true })

  -- Snacks Dashboard
  hl(0, "SnacksDashboardNormal", { fg = colors.text, bg = "NONE" })
  hl(0, "SnacksDashboardHeader", { fg = colors.primary })
  hl(0, "SnacksDashboardKey", { fg = colors.accent })
  hl(0, "SnacksDashboardDesc", { fg = colors.text })
  hl(0, "SnacksDashboardFooter", { fg = colors.muted })
  hl(0, "SnacksDashboardDir", { fg = colors.primary })
  hl(0, "SnacksDashboardFile", { fg = colors.text })
  hl(0, "SnacksDashboardSpecial", { fg = colors.secondary })

  -- Snacks Notifier
  hl(0, "SnacksNotifierTitle", { fg = colors.text, bold = true })
  hl(0, "SnacksNotifierIcon", { fg = colors.primary })
  hl(0, "SnacksNotifierBorder", { fg = colors.border })

  -- 6. Dynamic Plugin Reloads (Live)
  -- Lualine
  local lualine_status, lualine = pcall(require, "lualine")
  if lualine_status then
    lualine.setup({ options = { theme = M.get_lualine_theme(colors) } })
  end

  -- Bufferline
  local bufferline_status, bufferline = pcall(require, "bufferline")
  if bufferline_status then
    bufferline.setup({ highlights = M.get_bufferline_highlights(colors) })
  end
end

function M.get_lualine_theme(colors)
  return {
    normal = {
      a = { fg = colors.background, bg = colors.primary, bold = true },
      b = { fg = colors.text, bg = "NONE" },
      c = { fg = colors.text, bg = "NONE" },
    },
    insert = {
      a = { fg = colors.background, bg = colors.success, bold = true },
    },
    visual = {
      a = { fg = colors.background, bg = colors.secondary, bold = true },
    },
    replace = {
      a = { fg = colors.background, bg = colors.error, bold = true },
    },
    command = {
      a = { fg = colors.background, bg = colors.accent, bold = true },
    },
    inactive = {
      a = { fg = colors.muted, bg = "NONE", bold = true },
      b = { fg = colors.muted, bg = "NONE" },
      c = { fg = colors.muted, bg = "NONE" },
    },
  }
end

function M.get_bufferline_highlights(colors)
  return {
    separator = {
      fg = colors.border,
      bg = "NONE",
    },
    separator_selected = {
      fg = colors.border,
      bg = "NONE",
    },
    separator_visible = {
      fg = colors.border,
      bg = "NONE",
    },
    background = {
      fg = colors.muted,
      bg = "NONE",
    },
    buffer_selected = {
      fg = colors.text,
      bg = "NONE",
      bold = true,
    },
    buffer_visible = {
      fg = colors.muted,
      bg = "NONE",
    },
    close_button = {
      fg = colors.muted,
      bg = "NONE",
    },
    close_button_selected = {
      fg = colors.text,
      bg = "NONE",
    },
    close_button_visible = {
      fg = colors.muted,
      bg = "NONE",
    },
    fill = {
      bg = "NONE",
    },
  }
end


return M
