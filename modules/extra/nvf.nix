{
  config,
  lib,
  pkgs,
  ...
}:

let
  mkLua = expr: {
    _type = "lua-inline";
    inherit expr;
  };
in
{
  options.module.nvf.enable = lib.mkEnableOption "NVF" // {
    default = true;
  };

  config = lib.mkIf config.module.nvf.enable {
    home-manager.users.${config._module.args.username} = {
      imports = [ config._module.args.inputs.nvf.homeManagerModules.default ];
      programs.nvf = {
        enable = true;
        defaultEditor = true;
        settings = {
          vim = {
            globals.mapleader = " ";
            viAlias = true;
            vimAlias = true;

            options = {
              number = true;
              relativenumber = true;
              signcolumn = "yes";
              cursorline = true;
              termguicolors = true;
              scrolloff = 10;
              showmode = false;
              laststatus = 3;
              fillchars = "eob: ";
              expandtab = true;
              shiftwidth = 2;
              tabstop = 2;
              smartindent = true;
              softtabstop = 2;
              ignorecase = true;
              smartcase = true;
              hlsearch = false;
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

            autocmds = [
              {
                event = [ "TextYankPost" ];
                callback = mkLua "function() vim.highlight.on_yank() end";
                desc = "Highlight on yank";
              }
              {
                event = [ "BufReadPost" ];
                callback = mkLua ''
                  function()
                    local mark = vim.api.nvim_buf_get_mark(0, '"')
                    local lcount = vim.api.nvim_buf_line_count(0)
                    if mark[1] > 0 and mark[1] <= lcount then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
                  end
                '';
                desc = "Go to last cursor position";
              }
              {
                event = [
                  "ColorScheme"
                  "VimEnter"
                ];
                callback = mkLua ''
                  function()
                    local groups = { 'Normal', 'NormalFloat', 'SignColumn', 'EndOfBuffer', 'MsgArea', 'SnacksDashboardNormal', 'SnacksPickerNormal', 'SnacksPickerList' }
                    for _, group in ipairs(groups) do vim.api.nvim_set_hl(0, group, { bg = 'NONE', ctermbg = 'NONE' }) end
                  end
                '';
                desc = "Transparent background highlights";
              }
              {
                event = [ "FileType" ];
                pattern = [ "markdown" ];
                callback = mkLua "function() vim.opt_local.wrap = true; vim.opt_local.linebreak = true; vim.opt_local.breakindent = true end";
                desc = "Markdown wrapping settings";
              }
            ];

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
              # Window resize
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
              # Buffer navigation
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
                key = "<A-]> ";
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
              # Snacks Bindings (Smart CWD via explicit function call)
              {
                mode = "n";
                key = "<leader>ff";
                action = ":lua (function() local p=Snacks.picker.get({source='explorer'})[1]; Snacks.picker.files({cwd=p and p:cwd() or vim.fn.getcwd()}) end)()<cr>";
                silent = true;
                desc = "Find Files (Explorer Aware)";
              }
              {
                mode = "n";
                key = "<leader>fg";
                action = ":lua (function() local p=Snacks.picker.get({source='explorer'})[1]; Snacks.picker.grep({cwd=p and p:cwd() or vim.fn.getcwd()}) end)()<cr>";
                silent = true;
                desc = "Live Grep (Explorer Aware)";
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
                key = "<leader>fh";
                action = ":lua Snacks.picker.help()<cr>";
                silent = true;
                desc = "Find Help";
              }
              {
                mode = "n";
                key = "<leader>fs";
                action = ":lua Snacks.picker.smart()<cr>";
                silent = true;
                desc = "Smart Find Files";
              }
              {
                mode = "n";
                key = "<leader>fw";
                action = ":lua Snacks.picker.grep_word()<cr>";
                silent = true;
                desc = "Search Word";
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
                key = "<leader>th";
                action = ":lua Snacks.terminal.toggle(nil, { win = { position = 'bottom' } })<cr>";
                silent = true;
                desc = "Toggle Horizontal Terminal";
              }
              {
                mode = "n";
                key = "<leader>tv";
                action = ":lua Snacks.terminal.toggle(nil, { win = { position = 'right'  } })<cr>";
                silent = true;
                desc = "Toggle Vertical Terminal";
              }
              {
                mode = "n";
                key = "<leader>gg";
                action = ":lua Snacks.lazygit.open()<cr>";
                silent = true;
                desc = "Open LazyGit";
              }
              {
                mode = "n";
                key = "<leader>gb";
                action = ":lua Snacks.picker.git_branches()<cr>";
                silent = true;
                desc = "Git Branches";
              }
              {
                mode = "n";
                key = "<leader>gs";
                action = ":lua Snacks.picker.git_status()<cr>";
                silent = true;
                desc = "Git Status";
              }
              {
                mode = "n";
                key = "<leader>gB";
                action = ":lua Snacks.gitbrowse()<cr>";
                silent = true;
                desc = "Git Browse";
              }
              {
                mode = "n";
                key = "<leader>e";
                action = ":lua Snacks.explorer.open()<cr>";
                silent = true;
                desc = "Open Explorer";
              }
              {
                mode = "n";
                key = "<leader>bd";
                action = ":lua Snacks.bufdelete()<cr>";
                silent = true;
                desc = "Delete Buffer";
              }
              {
                mode = "n";
                key = "<leader>xx";
                action = ":lua Snacks.picker.diagnostics()<cr>";
                silent = true;
                desc = "Diagnostics";
              }
              # Mini Bindings
              {
                mode = "n";
                key = "<leader>j";
                action = ":lua MiniJump2d.start()<cr>";
                silent = true;
                desc = "Jump 2D";
              }
            ];

            binds.whichKey.enable = true;
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

            autocomplete.blink-cmp.enable = true;
            formatter.conform-nvim.enable = true;
            telescope.enable = false;
            git.gitsigns.enable = false;
            statusline.lualine.enable = true;

            visuals = {
              nvim-web-devicons.enable = false;
              indent-blankline.enable = false;
            };
            comments.comment-nvim.enable = false;

            mini = {
              ai = {
                enable = true;
                setupOpts.n_lines = 500;
              };
              comment.enable = true;
              diff.enable = true;
              jump2d.enable = true;
              operators.enable = true;
              move.enable = true;
              bufremove.enable = true;
              surround = {
                enable = true;
                setupOpts.mappings = {
                  add = "gsa";
                  delete = "gsd";
                  find = "gsf";
                  find_left = "gsF";
                  highlight = "gsh";
                  replace = "gsr";
                  update_n_lines = "gsn";
                };
              };
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
                    { section = "header"; }
                    {
                      section = "keys";
                      gap = 1;
                      padding = 1;
                    }
                  ];
                  preset = {
                    header = ''
                      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡰⢄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⢀⢄⠀⠀⡴⠁⠈⡆⠀⢀⡤⡀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠢⣄⠀⠀⡇⠀⡕⠀⢸⠀⢠⠃⠀⢮⠀⠹⠀⠀⣠⢾⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⣞⠀⢀⠇⠀⡇⠀⡸⠀⠈⣆⠀⡸⠀⢰⠀⠀⡇⣸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⠘⢶⣯⣊⣄⡨⠟⡡⠁⠐⢌⠫⢅⣢⣑⣵⠶⠁⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⠀⠀⠀⠀⠀⣼⣀⠀⢀⠒⠒⠂⠉⠀⠀⠀⠀⠁⠐⠒⠂⡀⠀⣸⣄⠀⠀⠀⠀⠀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⢮⣵⣶⣦⡩⡲⣄⠀⠀⣿⣿⣽⠲⠭⣥⣖⣂⣀⣀⣀⣀⣐⣢⡭⠵⠖⣿⣿⢫⠀⠀⣠⣖⣯⣶⣶⣮⡷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⢸⡟⢉⣉⠙⣿⣿⣦⠀⣿⣿⣿⣿⣷⣲⠶⠤⠭⣭⡭⠭⠴⠶⣖⣾⣿⣿⡿⢸⢀⣼⣿⡿⠋⣉⠉⢳⠁⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠮⣳⣴⣫⠂⠘⣿⣿⣇⢷⢻⣿⣿⣿⣿⣿⣷⣶⣶⣶⣶⣿⣿⣿⣿⣿⢿⢃⡟⣼⣿⣿⠁⠸⣘⣢⣚⠜⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⠈⢧⢻ ⣿⣿⣟⠻⣿⣿⣿⣿⠛⣩⣿⣿ ⢟⡞⢀⣿⣿⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣒⣒⣦⣄⣿⣿⣿⢀⡬⣟⣯  ⣿⢷⣼⡟⢿⣿⡿⣿⣿  ⡻⣤⡀⣿⣿⣸⡠⢔⣒⡒⢤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                      ⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⠀⠀⠀⠀⠀⠀⠀⢾⣟⣅⠉⢎⣽⣿⣿⡏⡟⣤⣮⣿⣿  ⡏⣿⠀⠀⣿⢡⣷  ⣿⣟⢎⣷⢻⣿⣿⣾⡟⠉⣽⡇⡇⠀⠀⠀⠀⠀⠀⠀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀
                      ⠀⠀⠀⠀⠀⠀⡴⣫⣭⣭⣍⡲⢄⠀⠀⠀⠀⠈⠻⠋⣠⡮⣻⣿⣿⠃⠳⣏⣼⣿⣿⣿⣿⡇⣿⣴⣴⣿⣾⣿⣿⣿⡿⣄⣩⠏⢸⣿⣿⣿⣧⡀⠛⠞⠁⠀⠀⠀⢀⣤⣺⣭⣭⣭⡝⢦⠀⠀⠀⠀⠀⠀
                      ⠀⠀⠀⠀⠀⢸⢹⡟⠁⠀⠉⢫⡳⣵⣄⠀⠀⢀⠴⢊⣿⣾⣿⣿⣿⠀⠀⠀⠻⣬⣽⣿⣿⣿⣿  ⣿⣿⣿⣿⣯⣵⠏⠀⠀⢸⣿⣿⣿⣿⣿⣗⢤⡀⠀⠀⣠⣿⢟⠟⠉⠀⠈⢻⢸⡆⠀⠀⠀⠀⠀
                      ⠀⠀⠀⠀⠀⠘⢏⢧⣤⡀⠀⠀⣇⢻⣿⣆⢔⢕⣵⠟⣏⣿⣿⣿⠋⣵⠚⠄⣾⣿⣿⣿⡿⠟⣛⣛⣛⣛⠻⣿⣿⣿⣿⣧⢰⠓⣏⠻⣿⣿⣿⢹⠻⣿⣿⢦⣸⣿⡏⡾⠀⠀⢠⣤⠎⡼⠀⠀⠀⠀⠀⠀
                      ⠀⠀⠀⠀⠀⠀⠈⠑⠂⠁⠀⠀⣿⠸⣿⢏⢂⣾⠇⠀⣿⣿⣿⡇⡆⠹⢷⣴⣿⡿⠟⠉⣐⡀⠄⣠⡄⡠⣁⡠⠙⠻⢿⣿⣴⡾⠃⢠⢹⣿⣿⢸⠀⢹⣿⣷⢹⣿⢃⡇⠀⠀⠈⠒⠋⠀⠀⠀⠀⠀⠀⠀
                      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⡀⣿⢀⣿⣿⡀⠀⢫⣿⣿⣷⣙⠒⠀⠄⠐⠂⣼⠾⣵⠾⠟⣛⣛⠺⢷⣮⠷⣢⠐⠂⠀⠀⠒⣣⣾⣿⡿⡎⠀⢠⣿⣿⡄⣿⣸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣟⣿⢸⣿⣿⣷⣄⡈⣾⣿⣿⣿⣿⣿⠻⡷⢺⠃⠠⠁⠈⠋⠀⠀⠉⠁⠙⡀⠘⡗⣾⠿⣿⣿⣿⣿⣿⡿⢀⣴⣿⣿⡿⢃⣯⣽⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣿⡆⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣵⡞⠀⠁⠐⢁⠎⠄⣠⠀⠀⡄⠀⢳⠈⠆⠈⠈⢳⣯⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⣸⡷⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣌⠛⢿⣿⣿⣿⣿⣿⣿⠿⠋⣠⣢⠂⠀⢂⠌⠀⠃⠀⠀⠘⠀⢢⡑⠀⠰⣵⡀⠻⢿⣿⣿⣿⣿⣿⣿⡿⠋⣰⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠳⣤⣭⢛⣻⠿⣿⣷⣶⢞⡟⡁⢀⢄⠎⠀⠀⠀⠀⠀⡀⠁⠀⠳⢠⠀⢈⢿⢳⣶⣾⣿⠿⣟⣛⣅⡴⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠙⠛⠻⠿⠿⡟⢜⠔⡠⢊⠔⠀⡆⠀⡆⠀⠀⢡⢰⢠⠀⢢⠱⣌⢂⠃⢿⠿⠿⠟⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⢤⣊⡰⠵⢺⠉⠸⠀⢰⢃⠀⠀⠀⠀⠀⠸⢸⠀⠀⡇⡞⡑⠬⢆⣑⢤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁⠀⠀⠀⠘⣾⡸⢀⡜⡾⡀⡇⠀⠀⡴⢠⢻⢦⠀⢃⡿⠀⠀⠀⠀⠈⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠳⡎⠀⠱⡡⠐⠀⠠⠃⢢⠋⠀⢧⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢤⡀⢀⠔⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠱⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                    '';
                    keys = [
                      {
                        key = "f";
                        desc = "Find File";
                        action = ":lua Snacks.picker.files()";
                      }
                      {
                        key = "n";
                        desc = "New File";
                        action = ":ene | startinsert";
                      }
                      {
                        key = "g";
                        desc = "Find Text";
                        action = ":lua Snacks.picker.grep()";
                      }
                      {
                        key = "r";
                        desc = "Recent Files";
                        action = ":lua Snacks.picker.recent()";
                      }
                      {
                        key = "e";
                        desc = "Explorer";
                        action = ":lua Snacks.explorer.open()";
                      }
                      {
                        key = "c";
                        desc = "Config";
                        action = ":e $MYVIMRC";
                      }
                      {
                        key = "q";
                        desc = "Quit";
                        action = ":q";
                        hidden = true;
                      }
                    ];
                  };
                };
                explorer.enabled = true;
                notifier.enabled = true;
                indent.enabled = true;
                scroll.enabled = true;
                bigfile.enabled = true;
                quickfile.enabled = true;
                statuscolumn.enabled = true;
                scope.enabled = true;
                image.enabled = true;
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
                      actions = {
                        focus_and_cd = mkLua ''
                          function(picker)
                            picker:action("explorer_focus")
                            vim.schedule(function()
                              vim.cmd("cd " .. picker:cwd())
                              Snacks.notify.info("CWD synchronized: " .. picker:cwd())
                            end)
                          end
                        '';
                      };
                      win = {
                        list = {
                          keys = {
                            "." = "focus_and_cd";
                          };
                        };
                      };
                    };
                  };
                };
              };
            };

            extraPlugins = with pkgs.vimPlugins; {
              # mini-nvim and snacks-nvim are now fully managed by native nvf modules
            };

            luaConfigPost = ''
              -- Dynamic Theme System (Quickshell integration)
              package.path = vim.fn.expand("$HOME/.cache/quickshell/themes/?.lua;") .. package.path
              local function get_palette()
                local status, c = pcall(require, "nvim")
                if not status then return nil end
                return { background = c.base00, surface = c.base01, surfaceAlt = c.base02, muted = c.base03, textMuted = c.base04, text = c.base05, textDim = c.base06, textBright = c.base07, error = c.base08, warning = c.base09, accent = c.base0A, success = c.base0B, info = c.base0C, primary = c[c.primaryIdx] or c.base0D, secondary = c[c.secondaryIdx] or c.base0E, brown = c.base0F, border = c.base01, borderActive = c[c.primaryIdx] or c.base0D, outline = c.base02 }
              end
              local function get_lualine_theme(colors)
                return { normal = { a = { fg = colors.background, bg = colors.primary, bold = true }, b = { fg = colors.text, bg = colors.surface }, c = { fg = colors.text, bg = "NONE" } }, insert = { a = { fg = colors.background, bg = colors.success, bold = true }, b = { fg = colors.text, bg = colors.surface } }, visual = { a = { fg = colors.background, bg = colors.secondary, bold = true }, b = { fg = colors.text, bg = colors.surface } }, replace = { a = { fg = colors.background, bg = colors.error, bold = true }, b = { fg = colors.text, bg = colors.surface } }, command = { a = { fg = colors.background, bg = colors.accent, bold = true }, b = { fg = colors.text, bg = colors.surface } }, inactive = { a = { fg = colors.muted, bg = "NONE", bold = true }, b = { fg = colors.muted, bg = "NONE" }, c = { fg = colors.muted, bg = "NONE" } } }
              end
              local function apply_theme()
                local colors = get_palette(); if not colors then return end
                local hl = vim.api.nvim_set_hl
                hl(0, "Normal", { fg = colors.text, bg = "NONE" }); hl(0, "NormalFloat", { fg = colors.text, bg = "NONE" }); hl(0, "FloatBorder", { fg = colors.borderActive, bg = "NONE" }); hl(0, "CursorLine", { bg = "NONE" }); hl(0, "CursorLineNr", { fg = colors.primary, bold = true }); hl(0, "LineNr", { fg = colors.textMuted }); hl(0, "Visual", { bg = colors.surfaceAlt }); hl(0, "Search", { bg = colors.primary, fg = colors.background }); hl(0, "IncSearch", { bg = colors.accent, fg = colors.background }); hl(0, "MatchParen", { fg = colors.accent, bold = true, underline = true }); hl(0, "WinSeparator", { fg = colors.border }); hl(0, "StatusLine", { fg = colors.text, bg = "NONE" }); hl(0, "StatusLineNC", { fg = colors.textMuted, bg = "NONE" }); hl(0, "Pmenu", { fg = colors.text, bg = "NONE" }); hl(0, "PmenuSel", { bg = colors.surfaceAlt, bold = true })
                hl(0, "Comment", { fg = colors.muted, italic = true }); hl(0, "Constant", { fg = colors.secondary }); hl(0, "String", { fg = colors.success }); hl(0, "Character", { fg = colors.success }); hl(0, "Number", { fg = colors.secondary }); hl(0, "Boolean", { fg = colors.secondary, bold = true }); hl(0, "Float", { fg = colors.secondary }); hl(0, "Identifier", { fg = colors.text }); hl(0, "Function", { fg = colors.primary, bold = true }); hl(0, "Statement", { fg = colors.accent }); hl(0, "Conditional", { fg = colors.accent, italic = true }); hl(0, "Repeat", { fg = colors.accent }); hl(0, "Label", { fg = colors.accent }); hl(0, "Operator", { fg = colors.info }); hl(0, "Keyword", { fg = colors.accent, italic = true }); hl(0, "Exception", { fg = colors.error }); hl(0, "PreProc", { fg = colors.accent }); hl(0, "Include", { fg = colors.accent }); hl(0, "Define", { fg = colors.accent }); hl(0, "Macro", { fg = colors.accent }); hl(0, "PreCondit", { fg = colors.accent }); hl(0, "Type", { fg = colors.info }); hl(0, "StorageClass", { fg = colors.info }); hl(0, "Structure", { fg = colors.info }); hl(0, "Typedef", { fg = colors.info }); hl(0, "Special", { fg = colors.secondary }); hl(0, "SpecialChar", { fg = colors.secondary }); hl(0, "Tag", { fg = colors.accent }); hl(0, "Delimiter", { fg = colors.textMuted }); hl(0, "SpecialComment", { fg = colors.muted, italic = true }); hl(0, "Debug", { fg = colors.warning }); hl(0, "Underlined", { underline = true }); hl(0, "Bold", { bold = true }); hl(0, "Italic", { italic = true }); hl(0, "Error", { fg = colors.error, bold = true }); hl(0, "Todo", { fg = colors.warning, bold = true })
                hl(0, "DiagnosticError", { fg = colors.error }); hl(0, "DiagnosticWarn", { fg = colors.warning }); hl(0, "DiagnosticInfo", { fg = colors.info }); hl(0, "DiagnosticHint", { fg = colors.accent }); hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = colors.error }); hl(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = colors.warning })
                hl(0, "MiniDiffSignAdd", { fg = colors.success, bg = "NONE" }); hl(0, "MiniDiffSignChange", { fg = colors.warning, bg = "NONE" }); hl(0, "MiniDiffSignDelete", { fg = colors.error, bg = "NONE" })
                hl(0, "SnacksPickerListCursorLine", { bg = "NONE" }); hl(0, "SnacksPickerSelected", { fg = colors.accent, bold = true }); hl(0, "SnacksPickerCaret", { fg = colors.accent, bold = true }); hl(0, "SnacksPickerMatch", { fg = colors.primary, bold = true }); hl(0, "SnacksPickerBorder", { fg = colors.borderActive }); hl(0, "SnacksPickerPromptBorder", { fg = colors.primary }); hl(0, "SnacksPickerInput", { fg = colors.text })
                hl(0, "SnacksDashboardNormal", { fg = colors.text, bg = "NONE" }); hl(0, "SnacksDashboardHeader", { fg = colors.primary }); hl(0, "SnacksDashboardKey", { fg = colors.accent }); hl(0, "SnacksDashboardDesc", { fg = colors.text }); hl(0, "SnacksDashboardFooter", { fg = colors.muted }); hl(0, "SnacksDashboardDir", { fg = colors.primary }); hl(0, "SnacksDashboardFile", { fg = colors.text }); hl(0, "SnacksDashboardSpecial", { fg = colors.secondary })
                hl(0, "SnacksNotifierBorder", { fg = colors.border }); hl(0, "SnacksNotifierTitle", { fg = colors.text, bold = true })
                hl(0, "SnacksIndent", { fg = colors.surfaceAlt }); hl(0, "SnacksIndentScope", { fg = colors.muted })
                hl(0, "LualineCwd", { fg = colors.primary, bold = true }); hl(0, "LualineCwdInactive", { fg = colors.muted, bold = true }); hl(0, "LualineBuffers", { fg = colors.background, bg = colors.primary, bold = true })
                if package.loaded["lualine"] then require("lualine").setup({ options = { theme = get_lualine_theme(colors) } }) end
              end
              local signal = vim.uv.new_signal(); if signal then vim.uv.signal_start(signal, "sigusr1", function() vim.schedule(function() package.loaded["nvim"] = nil; apply_theme(); print("Theme reloaded") end) end) end
              apply_theme()
            '';
          };
        };
      };

      xdg.desktopEntries.nvim = {
        name = "Neovim";
        genericName = "Text Editor";
        exec = "${config.globals.userTerminal} nvim %F";
        terminal = false;
        type = "Application";
        categories = [
          "Utility"
          "TextEditor"
        ];
        icon = "nvim";
      };
    };
  };
}
