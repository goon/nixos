return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader>e",
      function()
        require("yazi").yazi()
      end,
      desc = "Open Yazi",
    },
  },
  opts = {
    open_for_directories = true,
    change_neovim_cwd_on_close = true,
    floating_window_scaling_factor = 0.75,
  },
}
