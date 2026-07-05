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
            scrolloff = 10;
            laststatus = 3;
            expandtab = true;
            shiftwidth = 2;
            tabstop = 2;
            softtabstop = 2;
          };

          clipboard = {
            enable = true;
            providers.wl-copy.enable = true;
          };

          keymaps = [

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
              action = ":Pick files<cr>";
              silent = true;
              desc = "Find Files";
            }
            {
              mode = "n";
              key = "<leader>fg";
              action = ":Pick grep_live<cr>";
              silent = true;
              desc = "Live Grep";
            }
            {
              mode = "n";
              key = "<leader>fb";
              action = ":Pick buffers<cr>";
              silent = true;
              desc = "Find Buffers";
            }
            {
              mode = "n";
              key = "<leader>fh";
              action = ":Pick history<cr>";
              silent = true;
              desc = "Find History";
            }
            {
              mode = "n";
              key = "<leader>fk";
              action = ":Pick keymaps<cr>";
              silent = true;
              desc = "Find Keymaps";
            }
            {
              mode = "n";
              key = "<leader>fm";
              action = ":Pick marks<cr>";
              silent = true;
              desc = "Find Marks";
            }
            {
              mode = "n";
              key = "<leader>fr";
              action = ":Pick registers<cr>";
              silent = true;
              desc = "Find Registers";
            }

            {
              mode = "n";
              key = "<leader>e";
              action = "<cmd>lua MiniFiles.open()<cr>";
              silent = true;
              desc = "Files";
            }
            {
              mode = "n";
              key = "<leader>bd";
              action = ":lua MiniBufremove.delete()<cr>";
              silent = true;
              desc = "Delete Buffer";
            }
            {
              mode = "t";
              key = "<esc><esc>";
              action = "<C-\\><C-n><cmd>close<cr>";
              silent = true;
              desc = "Close terminal window";
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

          ui = {
            noice.enable = true;
            fastaction.enable = true;
          };

          lsp = {
            enable = true;
          };

          languages = {
            enableFormat = true;
            enableTreesitter = true;
            nix = {
              enable = true;
              format.type = [ "nixfmt" ];
            };
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

          formatter.conform-nvim = {
            enable = true;
          };

          mini = {
            basics = {
              enable = true;
              setupOpts = {
                options = {
                  basic = true;
                };
                mappings = {
                  windows = true;
                };
                autocommands = {
                  basic = true;
                };
              };
            };
            starter = {
              enable = true;
              setupOpts = {
                footer = "";
              };
            };
            files = {
              enable = true;
              setupOpts = {
                windows = {
                  preview = true;
                };
              };
            };
            animate.enable = true;
            bufremove.enable = true;
            completion.enable = true;
            cursorword.enable = true;
            diff.enable = true;
            extra.enable = true;
            hipatterns.enable = true;
            icons.enable = true;
            indentscope.enable = true;
            move.enable = true;
            notify.enable = true;
            pairs.enable = true;
            pick.enable = true;
            statusline.enable = true;
            surround.enable = true;
          };

          terminal.toggleterm = {
            enable = true;
            mappings.open = "<leader>t";
            lazygit.enable = true;
            setupOpts = {
              direction = "float";
              float_opts = {
                border = "curved";
              };
            };
          };

          autocmds = [
            {
              event = [ "FileType" ];
              pattern = [ "markdown" ];
              command = "setlocal wrap linebreak breakindent";
              desc = "Markdown Wrapping";
            }
          ];

          luaConfigPost = ''

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
