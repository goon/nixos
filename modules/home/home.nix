{
  pkgs,
  inputs,
  config,
  username,
  ...
}:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in
{
  imports = [ ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.${username} = {
    imports = [
      ../options.nix
      ./affinity.nix
      ./dots.nix
      ./firefox.nix
      ./xdg.nix
      ./git.nix
      ./nvf.nix
      ./kitty.nix
      ./fastfetch.nix
      ./bash.nix
      ./starship.nix
      ./yazi.nix
      ./opencode.nix
      inputs.spicetify-nix.homeManagerModules.default
      inputs.nvf.homeManagerModules.default
    ];

    home.username = username;
    home.homeDirectory = "/home/${username}";
    home.stateVersion = "25.11";

    dconf.enable = true;
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        font-name = "${config.globals.userFonts.sansSerif} 11";
        document-font-name = "${config.globals.userFonts.sansSerif} 11";
        monospace-font-name = "${config.globals.userFonts.monospace} 11";
        gtk-theme = "adw-gtk3";
        icon-theme = "Papirus";
        cursor-theme = "Bibata-Modern-Classic";
      };
    };

    # ----- GTK
    home.packages = with pkgs; [
      adw-gtk3
      papirus-icon-theme
      bibata-cursors
    ];

    # ----- Spicetify
    programs.spicetify = {
      enable = true;
      theme = spicePkgs.themes.comfy;
      colorScheme = "Mono";
      enabledExtensions = with spicePkgs.extensions; [
        hidePodcasts
      ];
    };
  };
}
