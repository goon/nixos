{
  config,
  lib,
  inputs,
  ...
}:

lib.module config "nvf" false {
  homeManager = {
    imports = [ inputs.nvf.homeManagerModules.default ];
    programs.nvf = {
      enable = true;
      defaultEditor = true;
      settings = {
        vim = {
          globals.mapleader = " ";
          vimAlias = true;

          options = {
            number = true;
            signcolumn = "yes";
            cursorline = true;
            scrolloff = 10;
            showmode = false;
            laststatus = 3;
            fillchars = "eob: ";
            expandtab = true;
            shiftwidth = 2;
            tabstop = 2;
            softtabstop = 2;
            ignorecase = true;
            smartcase = true;
            clipboard = "unnamedplus";
            updatetime = 250;
            timeoutlen = 300;
            undofile = true;
            swapfile = false;
            splitright = true;
            splitbelow = true;
            wrap = false;
          };

          keymaps = [
            {
              mode = "i";
              key = "<C-v>";
              action = "<C-r>+";
              silent = true;
              desc = "Paste from system clipboard";
            }
            # Window navigation
            {
              mode = [
                "n"
                "t"
              ];
              key = "<C-h>";
              action = "<C-\\><C-n><C-w>h";
              silent = true;
              desc = "Go to Left Window";
            }
            {
              mode = [
                "n"
                "t"
              ];
              key = "<C-j>";
              action = "<C-\\><C-n><C-w>j";
              silent = true;
              desc = "Go to Lower Window";
            }
            {
              mode = [
                "n"
                "t"
              ];
              key = "<C-k>";
              action = "<C-\\><C-n><C-w>k";
              silent = true;
              desc = "Go to Upper Window";
            }
            {
              mode = [
                "n"
                "t"
              ];
              key = "<C-l>";
              action = "<C-\\><C-n><C-w>l";
              silent = true;
              desc = "Go to Right Window";
            }
            {
              mode = "n";
              key = "<leader>v";
              action = "<C-w>v";
              silent = true;
              desc = "Vertical Split";
            }
            # Window resize

            {
              mode = "n";
              key = "<C-Left>";
              action = "<cmd>vertical resize -2<cr>";
              silent = true;
              desc = "Decrease Window Width";
            }
            {
              mode = "n";
              key = "<C-Right>";
              action = "<cmd>vertical resize +2<cr>";
              silent = true;
              desc = "Increase Window Width";
            }
            # Buffer navigation
            {
              mode = "n";
              key = "<Tab>";
              action = ":bnext<cr>";
              silent = true;
              desc = "Next Buffer";
            }
            {
              mode = "n";
              key = "<S-Tab>";
              action = ":bprevious<cr>";
              silent = true;
              desc = "Previous Buffer";
            }
            {
              mode = "n";
              key = "<leader>bb";
              action = "<cmd>e #<cr>";
              silent = true;
              desc = "Switch to Other Buffer";
            }
            {
              mode = "n";
              key = "<leader>bo";
              action = "<cmd>%bd|e#|bd#<cr>";
              silent = true;
              desc = "Delete Other Buffers";
            }
            # File operations
            {
              mode = [
                "i"
                "x"
                "n"
                "s"
              ];
              key = "<C-s>";
              action = "<cmd>w<cr><esc>";
              silent = true;
              desc = "Save File";
            }
            {
              mode = "n";
              key = "<leader>q";
              action = "<cmd>qa<cr>";
              silent = true;
              desc = "Quit";
            }
            {
              mode = "n";
              key = "<leader>s";
              action = "<cmd>wqa<cr>";
              silent = true;
              desc = "Save and Quit";
            }
            {
              mode = "n";
              key = "<leader>w";
              action = "<C-w>c";
              silent = true;
              desc = "Close Window";
            }
            {
              mode = "n";
              key = "<leader>n";
              action = "<cmd>enew<cr>";
              silent = true;
              desc = "New File";
            }

            {
              mode = "n";
              key = "<leader>ff";
              action = ":lua Snacks.picker.files()<cr>";
              silent = true;
              desc = "Find Files";
            }
            {
              mode = "n";
              key = "<leader>fg";
              action = ":lua Snacks.picker.grep()<cr>";
              silent = true;
              desc = "Live Grep";
            }
            {
              mode = "n";
              key = "<leader>fb";
              action = ":lua Snacks.picker.buffers()<cr>";
              silent = true;
              desc = "Find Buffers";
            }

            {
              mode = "n";
              key = "<leader>fr";
              action = ":lua Snacks.picker.registers()<cr>";
              silent = true;
              desc = "Registers";
            }
            {
              mode = "n";
              key = "<leader>fm";
              action = ":lua Snacks.picker.marks()<cr>";
              silent = true;
              desc = "Marks";
            }
            {
              mode = "n";
              key = "<leader>t";
              action = ":lua Snacks.terminal.toggle(nil, { win = { position = 'float', border = 'rounded', height = 0.6, width = 0.75 } })<cr>";
              silent = true;
              desc = "Terminal";
            }
            {
              mode = "n";
              key = "<leader>g";
              action = ":lua Snacks.lazygit.open()<cr>";
              silent = true;
              desc = "LazyGit";
            }
            {
              mode = "n";
              key = "<leader>e";
              action = ":lua Snacks.explorer({ layout = { preset = 'default' } })<cr>";
              silent = true;
              desc = "Explorer";
            }
            {
              mode = "n";
              key = "<leader>bd";
              action = ":lua Snacks.bufdelete()<cr>";
              silent = true;
              desc = "Delete Buffer";
            }
            {
              mode = "t";
              key = "<esc><esc>";
              action = "<C-\\><C-n>";
              silent = true;
              desc = "Exit terminal mode";
            }
          ];

          binds.whichKey = {
            enable = true;
            setupOpts = {
              icons = {
                mappings = false;
              };
            };
          };
          languages = {
            enableTreesitter = true;
            nix.enable = true;
            qml.enable = true;
            lua.enable = true;
            bash.enable = true;
            typescript.enable = true;
            markdown.enable = true;
            json.enable = true;
            yaml.enable = true;
            toml.enable = true;
            html.enable = true;
            css.enable = true;
          };

          lsp = {
            enable = true;
            mappings = {
              documentHighlight = null;
              listDocumentSymbols = null;
              addWorkspaceFolder = null;
              removeWorkspaceFolder = null;
              listWorkspaceFolders = null;
            };
          };

          autocomplete.blink-cmp.enable = true;
          formatter.conform-nvim = {
            enable = true;
            setupOpts = {
              format_on_save = {
                timeout_ms = 500;
                lsp_format = "fallback";
              };
            };
          };
          statusline.lualine.enable = true;

          mini = {
            comment.enable = true;
            diff.enable = true;
            hipatterns.enable = true;
            icons.enable = true;
            pairs.enable = true;
          };

          utility.snacks-nvim = {
            enable = true;
            setupOpts = {
              dashboard = {
                enabled = true;
                sections = [
                  {
                    section = "keys";
                    gap = 1;
                    padding = 1;
                  }
                ];
              };
              explorer.enabled = true;
              notifier.enabled = true;
              indent.enabled = true;
              scroll.enabled = true;
              bigfile.enabled = true;
              quickfile.enabled = true;
              statuscolumn.enabled = true;
              scope.enabled = true;
              rename.enabled = true;
              bufdelete.enabled = true;
              words.enabled = true;
              terminal.enabled = true;
              input.enabled = true;
              lazygit.enabled = true;
              picker = {
                enabled = true;
                auto_cd = true;
                sources = {
                  explorer = {
                    layout = {
                      preset = "default";
                      preview = true;
                    };
                    jump = {
                      close = true;
                    };
                  };
                };
              };
            };
          };

          luaConfigPost = ''
            -- Highlight On Yank
            vim.api.nvim_create_autocmd("TextYankPost", {
              callback = function() vim.highlight.on_yank() end,
            })

            -- Go To Last Cursor Position
            vim.api.nvim_create_autocmd("BufReadPost", {
              callback = function()
                local mark = vim.api.nvim_buf_get_mark(0, '"')
                local lcount = vim.api.nvim_buf_line_count(0)
                if mark[1] > 0 and mark[1] <= lcount then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
              end,
            })

            -- Markdown Wrapping 
            vim.api.nvim_create_autocmd("FileType", {
              pattern = "markdown",
              command = "setlocal wrap linebreak breakindent",
            })

            -- Theme & Signal Reloading 
            local theme_path = vim.fn.expand("$HOME/.cache/quickshell/themes/nvim.lua")

            local function apply_theme()
              pcall(dofile, theme_path)
            end

            local signal = vim.uv.new_signal()
            if signal then 
              vim.uv.signal_start(signal, "sigusr1", function() 
                vim.schedule(function() 
                  apply_theme()
                  print("Theme Reloaded")
                end) 
              end) 
            end

            apply_theme()
          '';
        };
      };
    };

  };
}
