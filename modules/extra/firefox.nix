{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.module.firefox.enable = lib.mkEnableOption "Firefox" // {
    default = false;
  };

  config = lib.mkIf config.module.firefox.enable {
    home-manager.users.${config._module.args.username} = {
      programs.firefox = {
        enable = true;
        configPath = "${config.globals.paths.config}/mozilla/firefox";

        profiles.default = {
          id = 0;
          isDefault = true;

          settings = {
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "widget.gtk.rounded-bottom-corners.enabled" = true;
            "browser.tabs.allow_transparent_browser" = true;
            "browser.display.use_document_fonts" = 0;
            "font.default.x-western" = "sans-serif";
            "font.name.sans-serif.x-western" = config.globals.userFonts.sansSerif;
            "font.name.serif.x-western" = config.globals.userFonts.sansSerif;
            "font.name.monospace.x-western" = config.globals.userFonts.monospace;
            "browser.ml.chat.enabled" = false;
            "browser.ml.enable" = false;
            "sidebar.position_start" = false;
            "browser.startup.page" = 1;
            "browser.startup.homepage" = "https://www.cosmos.so/";
          };
        };

        policies = {
          SearchEngines = {
            Default = "DuckDuckGo";
            Remove = [
              "Google"
              "Bing"
            ];
            Add = [
              {
                Name = "YouTube";
                Alias = "yt";
                URLTemplate = "https://www.youtube.com/results?search_query={searchTerms}";
                IconURL = "https://www.youtube.com/favicon.ico";
              }
              {
                Name = "Nix Packages";
                Alias = "np";
                URLTemplate = "https://search.nixos.org/packages?query={searchTerms}";
                IconURL = "https://nixos.org/favicon.ico";
              }
            ];
          };
        };
      };

      home.packages = with pkgs; [
        pywal16
        pywalfox-native
      ];
    };
  };
}
