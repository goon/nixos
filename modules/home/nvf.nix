{ pkgs, ... }:

{
  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        # ----- Leader
        globals.mapleader = " ";

        # ----- General
        viAlias = true;
        vimAlias = true;

        options = {
          # ----- UI
          number = true;
          relativenumber = true;
          signcolumn = "yes";
          cursorline = true;
          termguicolors = true;
          scrolloff = 10;
          showmode = false;
          laststatus = 3;
          fillchars = "eob: ";

          # ----- Indentation
          expandtab = true;
          shiftwidth = 2;
          tabstop = 2;
          smartindent = true;
          softtabstop = 2;

          # ----- Search
          ignorecase = true;
          smartcase = true;
          hlsearch = false;

          # ----- Performance
          mouse = "a";
          clipboard = "unnamedplus";
          updatetime = 250;
          timeoutlen = 300;
          undofile = true;
          swapfile = false;
          splitright = true;
          splitbelow = true;
          wrap = false;
          autoread = true;
        };

        # ----- Keymaps
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
            key = "<leader>h";
            action = "<C-w>s";
            silent = true;
            desc = "Horizontal Split";
          }
          {
            mode = "n";
            key = "<leader>cw";
            action = "<C-w>c";
            silent = true;
            desc = "Close Window";
          }
          {
            mode = "n";
            key = "<A-j>";
            action = "<C-w>J";
            silent = true;
            desc = "Move Window Down";
          }
          {
            mode = "n";
            key = "<A-k>";
            action = "<C-w>K";
            silent = true;
            desc = "Move Window Up";
          }
          {
            mode = "n";
            key = "<C-Up>";
            action = "<cmd>resize +2<cr>";
            silent = true;
            desc = "Increase Window Height";
          }
          {
            mode = "n";
            key = "<C-Down>";
            action = "<cmd>resize -2<cr>";
            silent = true;
            desc = "Decrease Window Height";
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
            mode = [
              "n"
              "t"
            ];
            key = "<A-[>";
            action = "<cmd>bprevious<cr>";
            silent = true;
            desc = "Previous Buffer";
          }
          {
            mode = [
              "n"
              "t"
            ];
            key = "<A-]>";
            action = "<cmd>bnext<cr>";
            silent = true;
            desc = "Next Buffer";
          }
          {
            mode = "n";
            key = "[b";
            action = ":bprevious<cr>";
            silent = true;
            desc = "Previous Buffer";
          }
          {
            mode = "n";
            key = "]b";
            action = ":bnext<cr>";
            silent = true;
            desc = "Next Buffer";
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
            key = "<leader>bd";
            action = ":bdelete<cr>";
            silent = true;
            desc = "Delete Buffer";
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
            desc = "Quit All";
          }
          {
            mode = "n";
            key = "<leader>wq";
            action = "<cmd>wqa<cr>";
            silent = true;
            desc = "Save and Quit All";
          }
          {
            mode = "n";
            key = "<leader>fn";
            action = "<cmd>enew<cr>";
            silent = true;
            desc = "New File";
          }
          {
            mode = "n";
            key = "<esc>";
            action = "<cmd>nohlsearch<cr>";
            silent = true;
            desc = "Clear hlsearch";
          }
          {
            mode = "n";
            key = "<leader>s";
            action = "<cmd>wa<cr>";
            silent = true;
            desc = "Save All Files";
          }
        ];

        # ----- Binds
        binds.whichKey.enable = true;

        # ----- Languages
        languages = {
          nix = {
            enable = true;
            lsp.servers = [ "nixd" ];
          };
          lua.enable = true;
          python.enable = true;
          go.enable = true;
          bash.enable = true;
          qml = {
            enable = true;
            lsp.enable = false;
          };
        };

        # ----- LSP
        lsp = {
          enable = true;
          mappings = {
            goToDefinition = "gd";
            goToDeclaration = "gD";
            listImplementations = "gI";
            goToType = "gy";
            listReferences = "gr";
            hover = "K";
            signatureHelp = "gK";
            renameSymbol = "<leader>cr";
            codeAction = "<leader>ca";
          };
        };

        # ----- Completion
        autocomplete.nvim-cmp.enable = true;

        # ----- Formatting
        formatter.conform-nvim.enable = true;

        # ----- Telescope
        telescope.enable = false;

        # ----- Git
        git.gitsigns.enable = true;

        # ----- UI
        statusline.lualine.enable = true;

        visuals = {
          nvim-web-devicons.enable = true;
          indent-blankline.enable = true;
        };

        comments.comment-nvim.enable = true;

        # ----- Mini
        mini = {
          surround = {
            enable = true;
            setupOpts = {
              mappings = {
                add = "gsa";
                delete = "gsd";
                find = "gsf";
                find_left = "gsF";
                highlight = "gsh";
                replace = "gsr";
                update_n_lines = "gsn";
              };
            };
          };
          hipatterns.enable = true;
          icons.enable = true;
          pairs.enable = true;
        };

        # ----- Extra
        extraPlugins = with pkgs.vimPlugins; {
          snacks = {
            package = snacks-nvim;
            setup = ''
                           require("snacks").setup({
                             dashboard = {
                               enabled = true,
                               sections = {
                                 { section = "header" },
                                 { section = "keys", gap = 1, padding = 1 },
                               },
                               preset = {
                                 header = [[
                                                                                    
                                                                                  
                    ████ ██████           █████      ██                     
                   ███████████             █████                             
                   █████████ ███████████████████ ███   ███████████   
                  █████████  ███    █████████████ █████ ██████████████   
                 █████████ ██████████ █████████ █████ █████ ████ █████   
               ███████████ ███    ███ █████████ █████ █████ ████ █████  
              ██████  █████████████████████ ████ █████ █████ ████ ██████ 
                                                                                    ]];
                                 keys = {
                                   { key = "f", desc = "Find File",       action = ":lua Snacks.picker.files()" },
                                   { key = "n", desc = "New File",        action = ":ene | startinsert" },
                                   { key = "g", desc = "Find Text",       action = ":lua Snacks.picker.grep()" },
                                   { key = "r", desc = "Recent Files",    action = ":lua Snacks.picker.recent()" },
                                   { key = "c", desc = "Config",          action = ":e $MYVIMRC" },
                                   { key = "q", desc = "Quit",            action = ":q", hidden = true },
                                 },
                               },
                             },
                             notifier = { enabled = true, },
                             indent = { enabled = true, },
                             scroll = { enabled = true, },
                             bigfile = { enabled = true, },
                             quickfile = { enabled = true, },
                             statuscolumn = { enabled = true, },
                             words = { enabled = true, },
                             terminal = { enabled = true, },
                             input = { enabled = true, },
                             lazygit = { enabled = true, },
                             picker = { enabled = true, },
                           })
            '';
          };
          trouble = {
            package = trouble-nvim;
            setup = "pcall(function() require('trouble').setup({}) end)";
          };
          opencode = {
            package = opencode-nvim;
          };
          flash = {
            package = flash-nvim;
            setup = "pcall(function() require('flash').setup({}) end)";
          };
          grug-far = {
            package = grug-far-nvim;
            setup = "pcall(function() require('grug-far').setup({}) end)";
          };
          yanky = {
            package = yanky-nvim;
            setup = "pcall(function() require('yanky').setup({}) end)";
          };
          yazi = {
            package = yazi-nvim;
            setup = ''
              pcall(function() 
                require("yazi").setup({
                  open_for_directories = true,
                  change_neovim_cwd_on_close = true,
                  floating_window_scaling_factor = 0.75,
                })
              end)
            '';
          };
        };

        # ----- Theme Bridge Integration
        luaConfigPost = ''
          -- Add Quickshell cache to the Lua search path
          package.path = vim.fn.expand("$HOME/.cache/quickshell/themes/?.lua;") .. package.path

          -- [[ Dynamic Theme Logic (Consolidated from Lua files) ]]

          local function get_palette()
            local status, c = pcall(require, "nvim")
            if not status then return nil end
            return {
              background = c.base00, surface = c.base01, surfaceAlt = c.base02,
              muted = c.base03, textMuted = c.base04, text = c.base05,
              textDim = c.base06, textBright = c.base07, error = c.base08,
              warning = c.base09, accent = c.base0A, success = c.base0B,
              info = c.base0C, primary = c[c.primaryIdx] or c.base0D,
              secondary = c[c.secondaryIdx] or c.base0E, brown = c.base0F,
              border = c.base01, borderActive = c[c.primaryIdx] or c.base0D,
              outline = c.base02,
            }
          end

          local function get_lualine_theme(colors)
            return {
              normal = { a = { fg = colors.background, bg = colors.primary, bold = true }, b = { fg = colors.text, bg = colors.surface }, c = { fg = colors.text, bg = "NONE" } },
              insert = { a = { fg = colors.background, bg = colors.success, bold = true }, b = { fg = colors.text, bg = colors.surface } },
              visual = { a = { fg = colors.background, bg = colors.secondary, bold = true }, b = { fg = colors.text, bg = colors.surface } },
              replace = { a = { fg = colors.background, bg = colors.error, bold = true }, b = { fg = colors.text, bg = colors.surface } },
              command = { a = { fg = colors.background, bg = colors.accent, bold = true }, b = { fg = colors.text, bg = colors.surface } },
              inactive = { a = { fg = colors.muted, bg = "NONE", bold = true }, b = { fg = colors.muted, bg = "NONE" }, c = { fg = colors.muted, bg = "NONE" } },
            }
          end

          local function apply_theme()
            local colors = get_palette()
            if not colors then return end
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

            -- 5. Lualine Custom Groups
            hl(0, "LualineCwd", { fg = colors.primary, bold = true })
            hl(0, "LualineCwdInactive", { fg = colors.muted, bold = true })
            hl(0, "LualineBuffers", { fg = colors.background, bg = colors.primary, bold = true })

            -- Lualine Reload (if loaded)
            if package.loaded["lualine"] then
              require("lualine").setup({ options = { theme = get_lualine_theme(colors) } })
            end
          end

          -- Signal Listener for Live Reload (SIGUSR1)
          local signal = vim.uv.new_signal()
          if signal then
            vim.uv.signal_start(signal, "sigusr1", function()
              vim.schedule(function()
                package.loaded["nvim"] = nil
                apply_theme()
                print("Theme reloaded")
              end)
            end)
          end

          -- Initial application
          apply_theme()

          -- Re-apply some snacks-specific keymaps that are easier in Lua
          local map = vim.keymap.set
          map("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Find Files" })
          map("n", "<leader>fg", function() Snacks.picker.grep() end, { desc = "Live Grep" })
          map("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "Find Buffers" })
          map("n", "<leader>fh", function() Snacks.picker.help() end, { desc = "Find Help" })
          map("n", "<leader>fs", function() Snacks.picker.smart() end, { desc = "Smart Find Files" })
          map("n", "<leader>fw", function() Snacks.picker.grep_word() end, { desc = "Search Word" })

          map("n", "<leader>th", function() Snacks.terminal.toggle(nil, { win = { position = "bottom" } }) end, { desc = "Toggle Horizontal Terminal" })
          map("n", "<leader>tv", function() Snacks.terminal.toggle(nil, { win = { position = "right" } }) end, { desc = "Toggle Vertical Terminal" })
          map("n", "<C-a>", function() Snacks.terminal.toggle("opencode", { win = { position = "right" } }) end, { desc = "Toggle Opencode AI" })

          map("n", "<leader>gg", function() Snacks.lazygit.open() end, { desc = "Open LazyGit" })
          map("n", "<leader>gb", function() Snacks.picker.git_branches() end, { desc = "Git Branches" })
          map("n", "<leader>gs", function() Snacks.picker.git_status() end, { desc = "Git Status" })

          -- Yazi Integration
          map("n", "<leader>e", function() require("yazi").yazi() end, { desc = "Open Yazi" })

          -- Diagnostics Navigation
          map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next Diagnostic" })
          map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Prev Diagnostic" })
          map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })

          -- [[ Autocommands and Utilities ]]

          -- Highlight on yank
          vim.api.nvim_create_autocmd("TextYankPost", {
            callback = function() vim.highlight.on_yank() end,
          })

          -- Go to last loc when opening a buffer
          vim.api.nvim_create_autocmd("BufReadPost", {
            callback = function()
              local mark = vim.api.nvim_buf_get_mark(0, '"')
              local lcount = vim.api.nvim_buf_line_count(0)
              if mark[1] > 0 and mark[1] <= lcount then
                pcall(vim.api.nvim_win_set_cursor, 0, mark)
              end
            end,
          })

          -- Transparency (Force inheritance of terminal background)
          local function transparent_bg()
            local groups = {
              "Normal", "NormalFloat", "SignColumn", "EndOfBuffer", "MsgArea",
              "SnacksDashboardNormal", "SnacksPickerNormal", "SnacksPickerList"
            }
            for _, group in ipairs(groups) do
              vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
            end
          end
          vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
            callback = transparent_bg,
          })

          -- Filesystem Watcher
          local function setup_file_watch()
            local function do_refresh()
              vim.schedule(function() vim.cmd("checktime") end)
            end

            if vim.fs.watch then
              local cwd = vim.fn.getcwd()
              pcall(function() 
                vim.fs.watch(cwd, function() do_refresh() end)
              end)
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

          -- Mini.hipatterns extra config (hex colors)
          pcall(function() 
            local hipatterns = require("mini.hipatterns")
            hipatterns.setup({
              highlighters = {
                hex_color = hipatterns.gen_highlighter.hex_color(),
              },
            })
          end)

          -- Mini.icons mocking nvim-web-devicons
          pcall(function() require("mini.icons").mock_nvim_web_devicons() end)

          -- Toggle indent guides
          map("n", "<leader>ti", function() Snacks.toggle.indent():toggle() end, { desc = "Toggle Indent Guides" })

          -- Enable line wrapping for markdown files only (from options.lua)
          vim.api.nvim_create_autocmd("FileType", {
            pattern = "markdown",
            callback = function()
              vim.opt_local.wrap = true
              vim.opt_local.linebreak = true
              vim.opt_local.breakindent = true
            end,
          })
        '';
      };
    };
  };
}
