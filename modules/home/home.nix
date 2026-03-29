{ pkgs, inputs, fonts, user, ... }:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in
{
  imports = [ ./affinity.nix ];
  # Home-Manager configuration (system-level)
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # Required for dconf/GTK integration
  programs.dconf.enable = true;

  home-manager.users.${user} = {
    imports = [
      ./dots.nix
      ./firefox.nix
      ./xdg.nix
      ./git.nix
      ./nautilus.nix
      inputs.spicetify-nix.homeManagerModules.default
    ];

    home.username = user;
    home.homeDirectory = "/home/${user}";
    home.stateVersion = "25.11";

    # Enable dconf for GNOME app settings
    dconf.enable = true;

    # Nautilus preferences are managed in ./nautilus.nix
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        font-name = "${fonts.sansSerif} 11";
        document-font-name = "${fonts.sansSerif} 11";
        monospace-font-name = "${fonts.monospace} 11";
        gtk-theme = "adw-gtk3";
        icon-theme = "Papirus";
        cursor-theme = "Bibata-Modern-Classic";
      };
    };

    # Install GTK theme packages (managed by quickshell script, not Nix symlinks)
    home.packages = with pkgs; [
      adw-gtk3
      papirus-icon-theme
      bibata-cursors
    ];

    # Spicetify Configuration (Spotify theming)
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
