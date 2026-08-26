{
  config,
  lib,
  ...
}:
lib.module config "kitty" false {
  homeManager = { globals, ... }: {
    programs.kitty = {
      enable = true;
      settings = {
        confirm_os_window_close = 0;
        allow_remote_control = "yes";
        listen_on = "unix:/tmp/kitty";
        font_family = globals.userFonts.monospace;
        font_size = "12";
        cursor_shape = "block";
        cursor_trail = 10;
        cursor_trail_start_threshold = 0;
        cursor_trail_decay = "0.01 0.05";
        window_padding_width = "20";
        resize_in_steps = "yes";
        enabled_layouts = "tall";
        tab_bar_edge = "top";
        tab_bar_margin_height = "20 20";
        tab_bar_style = "powerline";
        tab_powerline_style = "round";
        active_border_color = "none";
      };

      keybindings = {
        "ctrl+t" = "new_tab";
        "ctrl+shift+q" = "close_tab";
        "ctrl+shift+enter" = "new_window";
        "ctrl+shift+w" = "close_window";
        "ctrl+shift+]" = "next_window";
        "ctrl+shift+[" = "previous_window";
      };

      extraConfig = ''
        include ~/.cache/yaks/themes/kitty.conf
        symbol_map U+e000-U+e00a,U+ea60-U+ebeb,U+e0a0-U+e0c8,U+e0ca,U+e0cc-U+e0d4,U+e200-U+e2a9,U+e300-U+e3eb,U+e5fa-U+e6b1,U+e700-U+e7c5,U+f000-U+f2e0,U+f300-U+f372,U+f400-U+f532,U+f0001-U+f1af0 Symbols Nerd Font Mono
      '';
    };

    xdg.configFile."kitty/sessions/nix.session".text = ''
      cd ${globals.repo}
      layout splits
      launch --var window=editor nvim
      launch --location=vsplit --bias=40 opencode
      focus_matching_window var:window=editor
    '';

    xdg.configFile."kitty/sessions/yaks.session".text = ''
      cd ${globals.repo}/modules/session/yaks
      layout splits
      launch --var window=editor nvim
      launch --location=vsplit --bias=40 opencode
      focus_matching_window var:window=editor
    '';
  };
}
