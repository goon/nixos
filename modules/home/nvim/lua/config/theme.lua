local M = {}

function M.apply()
  local palette = require("config.palette")
  local colors = palette.get_colors()
  if not colors then
    return
  end

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


  -- 4. Plugin Specifics
  -- Gitsigns
  hl(0, "GitSignsAdd", { fg = colors.success, bg = "NONE" })
  hl(0, "GitSignsChange", { fg = colors.warning, bg = "NONE" })
  hl(0, "GitSignsDelete", { fg = colors.error, bg = "NONE" })

  -- Snacks Picker
  hl(0, "SnacksPickerListCursorLine", { bg = "NONE" })
  hl(0, "SnacksPickerSelected", { fg = colors.accent, bold = true })
  hl(0, "SnacksPickerCaret", { fg = colors.accent, bold = true })
  hl(0, "SnacksPickerMatch", { fg = colors.primary, bold = true })
  hl(0, "SnacksPickerBorder", { fg = colors.borderActive })
  hl(0, "SnacksPickerPromptBorder", { fg = colors.primary })
  hl(0, "SnacksPickerInput", { fg = colors.text })

  -- Snacks Dashboard
  hl(0, "SnacksDashboardNormal", { fg = colors.text, bg = "NONE" })
  hl(0, "SnacksDashboardHeader", { fg = colors.primary })
  hl(0, "SnacksDashboardKey", { fg = colors.accent })
  hl(0, "SnacksDashboardDesc", { fg = colors.text })
  hl(0, "SnacksDashboardFooter", { fg = colors.muted })
  hl(0, "SnacksDashboardDir", { fg = colors.primary })
  hl(0, "SnacksDashboardFile", { fg = colors.text })
  hl(0, "SnacksDashboardSpecial", { fg = colors.secondary })

  hl(0, "SnacksNotifierBorder", { fg = colors.border })
  hl(0, "SnacksNotifierTitle", { fg = colors.text, bold = true })

  -- 6. Dynamic Plugin Reloads
  -- Lualine
  hl(0, "LualineCwd", { fg = colors.primary, bold = true })
  hl(0, "LualineCwdInactive", { fg = colors.muted, bold = true })
  hl(0, "LualineBuffers", { fg = colors.background, bg = colors.primary, bold = true })

  -- Reload lualine (if loaded)
  if package.loaded["lualine"] then
    local lualine = require("lualine")
    lualine.setup({ options = { theme = M.get_lualine_theme(colors) } })
  end
end

function M.get_lualine_theme(colors)
  return {
    normal = {
      a = { fg = colors.background, bg = colors.primary, bold = true },
      b = { fg = colors.text, bg = colors.surface },
      c = { fg = colors.text, bg = "NONE" },
    },
    insert = {
      a = { fg = colors.background, bg = colors.success, bold = true },
      b = { fg = colors.text, bg = colors.surface },
    },
    visual = {
      a = { fg = colors.background, bg = colors.secondary, bold = true },
      b = { fg = colors.text, bg = colors.surface },
    },
    replace = {
      a = { fg = colors.background, bg = colors.error, bold = true },
      b = { fg = colors.text, bg = colors.surface },
    },
    command = {
      a = { fg = colors.background, bg = colors.accent, bold = true },
      b = { fg = colors.text, bg = colors.surface },
    },
    inactive = {
      a = { fg = colors.muted, bg = "NONE", bold = true },
      b = { fg = colors.muted, bg = "NONE" },
      c = { fg = colors.muted, bg = "NONE" },
    },
  }
end

function M.setup()
  -- Setup signal listener for live reload (SIGUSR1)
  local signal = vim.uv.new_signal()
  if signal then
    vim.uv.signal_start(signal, "sigusr1", function()
      vim.schedule(function()
        package.loaded["nvim"] = nil
        package.loaded["config.palette"] = nil
        package.loaded["config.theme"] = nil
        M.apply()
        print("Theme reloaded")
      end)
    end)
  end

  -- Initial application
  M.apply()
end

return M
