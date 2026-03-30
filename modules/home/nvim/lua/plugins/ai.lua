return {
  -- OpenCode AI Integration (Integrated UI)
  {
    "nickjvandyke/opencode.nvim",
    version = "*",
    dependencies = { "folke/snacks.nvim" },
    config = function()
      -- vim.g.opencode_opts = {}
      vim.o.autoread = true -- Required for opts.events.reload

      -- Integrated keymaps
      vim.keymap.set({ "n", "x" }, "<C-a>", function()
        require("opencode").ask("@this: ", { submit = true })
      end, { desc = "Ask opencode…" })

      vim.keymap.set({ "n", "x" }, "<C-x>", function()
        require("opencode").select()
      end, { desc = "Execute opencode action…" })

      vim.keymap.set({ "n", "t" }, "<C-.>", function()
        Snacks.terminal.toggle("opencode", {
          win = { position = "right" }
        })
      end, { desc = "Toggle opencode" })
    end,
  },
}
