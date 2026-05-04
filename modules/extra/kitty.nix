{ config, lib, ... }:

let
  inherit (config._module.args) username;
  inherit (config._module.args) repoName;
in
{
  options.module.kitty.enable = lib.mkEnableOption "Kitty" // {
    default = true;
  };

  config = lib.mkIf config.module.kitty.enable {
    home-manager.users.${username} = {
      programs.kitty = {
        enable = true;
        settings = {
          confirm_os_window_close = 0;
          allow_remote_control = "yes";
          listen_on = "unix:/tmp/kitty";
          font_family = config.globals.userFonts.monospace;
          font_size = "11.0";
          cursor_shape = "block";
          cursor_trail = 10;
          cursor_trail_start_threshold = 0;
          cursor_trail_decay = "0.01 0.05";
          cursor_blink = true;
          window_padding_width = 20;
          enabled_layouts = "tall";
          tab_bar_edge = "top";
          tab_bar_margin_height = "12 12";
          tab_bar_style = "powerline";
          tab_powerline_style = "round";
        };

        keybindings = {
          "ctrl+t" = "new_tab";
          "ctrl+shift+q" = "close_tab";
          "ctrl+shift+enter" = "new_window";
          "ctrl+shift+w" = "close_window";
          "ctrl+shift+]" = "next_window";
          "ctrl+shift+[" = "previous_window";
          "f4" = "goto_session ${config.globals.paths.config}/kitty/sessions/ --sort-by=alphabetical";
        };

        extraConfig = ''
          include ~/.cache/quickshell/themes/kitty.conf
          symbol_map U+e000-U+e00a,U+ea60-U+ebeb,U+e0a0-U+e0c8,U+e0ca,U+e0cc-U+e0d4,U+e200-U+e2a9,U+e300-U+e3eb,U+e5fa-U+e6b1,U+e700-U+e7c5,U+f000-U+f2e0,U+f300-U+f372,U+f400-U+f532,U+f0001-U+f1af0 Symbols Nerd Font Mono
        '';
      };

      xdg.configFile."kitty/sessions/nix.session".text = ''
        cd ~/${repoName}/
        layout splits
        launch nvim
        launch --location=vsplit --bias=40 opencode
      '';

      xdg.configFile."kitty/sessions/qs.session".text = ''
        cd ~/${repoName}/modules/home/quickshell
        layout splits
        launch nvim
        launch --location=vsplit --bias=40 opencode
      '';
    };
  };
}
