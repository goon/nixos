{ fonts, ... }:
{
  programs.firefox = {
    enable = true;
    configPath = ".config/mozilla/firefox";

    profiles.default = {
      id = 0;
      isDefault = true;

      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.tabs.allow_transparent_browser" = true;
        "browser.display.use_document_fonts" = 0;
        "font.default.x-western" = "sans-serif";
        "font.name.sans-serif.x-western" = fonts.sansSerif;
        "font.name.serif.x-western" = fonts.sansSerif;
        "font.name.monospace.x-western" = fonts.monospace;
        "browser.ml.chat.enabled" = false;
        "browser.ml.enable" = false;
        "sidebar.position_start" = false;
        "browser.startup.page" = 3;
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

}
