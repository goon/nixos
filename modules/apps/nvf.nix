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
            clipboard = "unnamedplus";
            scrolloff = 10;
            laststatus = 3;
            expandtab = true;
            shiftwidth = 2;
            tabstop = 2;
            softtabstop = 2;
          };

          keymaps = [

            {
              mode = "i";
              key = "<C-v>";
              action = "<C-r>+";
              silent = true;
              desc = "Paste from system clipboard";
            }
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
              key = "<leader>t";
              action = "<cmd>ToggleTerm direction=float<cr>";
              silent = true;
              desc = "Terminal";
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
            setupOpts = {
              format_on_save = {
                timeout_ms = 500;
                lsp_format = "fallback";
              };
            };
          };

          mini = {
            basics = {
              enable = true;
              setupOpts = {
                options = {
                  basic = true;
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
            animate.enable = true;
            bufremove.enable = true;
            completion.enable = true;
            cursorword.enable = true;
            diff.enable = true;
            extra.enable = true;
            files.enable = true;
            hipatterns.enable = true;
            icons.enable = true;
            indentscope.enable = true;
            notify.enable = true;
            pairs.enable = true;
            pick.enable = true;
            statusline.enable = true;
          };

          terminal.toggleterm = {
            enable = true;
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
