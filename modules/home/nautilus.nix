{ pkgs, user, repoName, ... }:

{
  home.packages = with pkgs; [
    nautilus
    sushi # File Preview for Nautilus
    ffmpegthumbnailer # Video thumbnails for Nautilus
  ];

  dconf.settings = {
    "org/gnome/nautilus/preferences" = {
      show-hidden-files = true;
      default-folder-viewer = "list-view";
      show-delete-permanently = true;
    };
  };

  # GTK Bookmarks
  xdg.configFile."gtk-3.0/bookmarks" = {
    force = true;
    text = ''
      file:///home/${user}/${repoName} Nix
      file:///home/${user}/Downloads Downloads
      file:///home/${user}/Documents Documents
      file:///home/${user}/Pictures Pictures
      file:///home/${user}/Music Music
      file:///home/${user}/Videos Videos
    '';
  };
}
