{
  pkgs,
  inputs,
  fonts,
  user,
  repoName,
  ...
}:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in
{
  imports = [ ./affinity.nix ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  programs.dconf.enable = true;

  home-manager.users.${user} = {
    _module.args = {
      inherit fonts user repoName;
    };

    imports = [
      ./dots.nix
      ./firefox.nix
      ./xdg.nix
      ./git.nix
      ./nautilus.nix
      ./nvf.nix
      ./kitty.nix
      ./fastfetch.nix
      ./bash.nix
      ./starship.nix
      ./mpv.nix
      ./yazi.nix
      ./opencode.nix
      inputs.spicetify-nix.homeManagerModules.default
      inputs.nvf.homeManagerModules.default
    ];

    home.username = user;
    home.homeDirectory = "/home/${user}";
    home.stateVersion = "25.11";

    dconf.enable = true;
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
