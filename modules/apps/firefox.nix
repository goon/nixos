{
  config,
  lib,
  pkgs,
  ...
}:
lib.module config "firefox" false {
  homeManager =
    {
      config,
      globals,
      ...
    }:
    {
      home.packages = with pkgs; [
        pywal16
        pywalfox-native
      ];
      programs.firefox = {
        enable = true;
        configPath = "${config.xdg.configHome}/mozilla/firefox";

        profiles.default = {
          id = 0;
          isDefault = true;

          settings = {
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "widget.gtk.rounded-bottom-corners.enabled" = true;
            "browser.tabs.allow_transparent_browser" = true;
            "browser.display.use_document_fonts" = 1;
            "font.default.x-western" = "sans-serif";
            "font.name.sans-serif.x-western" = globals.userFonts.sansSerif;
            "font.name.serif.x-western" = globals.userFonts.sansSerif;
            "font.name.monospace.x-western" = globals.userFonts.monospace;
            "browser.ml.chat.enabled" = false;
            "browser.ml.enable" = false;
            "sidebar.position_start" = false;
            "browser.startup.page" = 1;
            "browser.startup.homepage" = "https://duckduckgo.com/";

            "media.ffmpeg.vaapi.enabled" = true;
            "media.ffmpeg.vaapi-drm.enabled" = true;
            "media.hardware-video-decoding.enabled" = true;
            "media.ffvpx.enabled" = false;
            "gfx.webrender.all" = true;
            "gfx.webrender.enabled" = true;
            "network.predictor.enable" = true;
            "network.dns.disablePrefetch" = false;
          };
          search = {
            force = true;
            default = "ddg";
            order = [
              "ddg"
              "youtube"
              "nix-packages"
              "osrs"
            ];
            engines = {
              ddg = {
                isAppProvided = true;
              };
              youtube = {
                name = "YouTube";
                urls = [ { template = "https://www.youtube.com/results?search_query={searchTerms}"; } ];
                icon = "https://www.youtube.com/favicon.ico";
                definedAliases = [ "@yt" ];
              };
              nix-packages = {
                name = "Nix Packages";
                urls = [
                  {
                    template = "https://search.nixos.org/packages";
                    params = [
                      {
                        name = "type";
                        value = "packages";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@np" ];
              };
              osrs = {
                name = "OSRS";
                urls = [ { template = "https://oldschool.runescape.wiki/w/{searchTerms}"; } ];
                icon = "https://oldschool.runescape.wiki/favicon.ico";
                definedAliases = [ "@osrs" ];
              };
              google.metaData.hidden = true;
              bing.metaData.hidden = true;
              perplexity.metaData.hidden = true;
              wikipedia.metaData.hidden = true;
              ebay-uk.metaData.hidden = true;
            };
          };
          userChrome = ''
            .titlebar-close { display: none !important; }

            :root {
              --toolbarbutton-outline: none;
              --toolbarbutton-outline-color: none;
              --toolbarbutton-outline-color-hover: none;
              --toolbarbutton-outline-color-active: none;
              --toolbarbutton-outline-color-selected: none;
            }

            toolbar .toolbarbutton-1,
            toolbar .toolbarbutton-1 > *,
            toolbar .bookmark-item,
            toolbar .bookmark-item > * {
              appearance: none !important;
              border: none !important;
              box-shadow: none !important;
            }

            toolbar .toolbarbutton-1 > :is(.toolbarbutton-icon, .toolbarbutton-text, .toolbarbutton-badge-stack),
            toolbar .bookmark-item > *,
            toolbar .bookmark-item:not(:focus-visible) {
              outline: none !important;
            }

            toolbar .toolbarbutton-1:focus-visible > :is(.toolbarbutton-icon, .toolbarbutton-text, .toolbarbutton-badge-stack),
            toolbar .bookmark-item:focus-visible {
              outline: var(--focus-outline) !important;
              outline-offset: var(--focus-outline-inset) !important;
            }
          '';
          userContent = ''
            moz-page-nav-button {
              --page-nav-button-border-color: transparent !important;
              --page-nav-button-border-color-hover: transparent !important;
              --page-nav-button-border-color-active: transparent !important;
              --button-border-color-ghost-hover: transparent !important;
              --button-border-color-ghost-active: transparent !important;
            }
          '';
        };
      };

      home.file.".mozilla/native-messaging-hosts/pywalfox.json".text = builtins.toJSON {
        name = "pywalfox";
        description = "Automatically theme your browser using the colors generated by Pywal";
        path = "${pkgs.pywalfox-native}/bin/pywalfox";
        type = "stdio";
        allowed_extensions = [ "pywalfox@frewacom.org" ];
      };
    };
}
