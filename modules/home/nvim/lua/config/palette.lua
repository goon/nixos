local M = {}

function M.get_colors()
  local status, c = pcall(require, "nvim")
  if not status then
    return nil
  end

  -- Semantic mappings from Base16 palette (sourced from Quickshell cache)
  return {
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
end

return M
