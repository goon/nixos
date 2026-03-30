return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "basedpyright", "bashls", "qmlls" },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Lua
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      -- Python
      vim.lsp.config("basedpyright", {})

      -- Bash
      vim.lsp.config("bashls", {})

      -- QML (requires qtdeclarative typically)
      vim.lsp.config("qmlls", {})

      -- Nix
      vim.lsp.config("nixd", {})

      -- LSP keymaps (set when LSP attaches to buffer)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp_keymaps", { clear = true }),
        callback = function(event)
          local bufmap = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          bufmap("gd", vim.lsp.buf.definition, "Go to Definition")
          bufmap("gr", vim.lsp.buf.references, "Find References")
          bufmap("gI", vim.lsp.buf.implementation, "Go to Implementation")
          bufmap("gy", vim.lsp.buf.type_definition, "Go to Type Definition")
          bufmap("gD", vim.lsp.buf.declaration, "Go to Declaration")
          bufmap("K", vim.lsp.buf.hover, "Hover Documentation")
          bufmap("gK", vim.lsp.buf.signature_help, "Signature Help")
          bufmap("<C-k>", vim.lsp.buf.signature_help, "Signature Help", "i")
          bufmap("<leader>ca", vim.lsp.buf.code_action, "Code Action", { "n", "x" })
          bufmap("<leader>cr", vim.lsp.buf.rename, "Rename Symbol")
        end,
      })
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
}
