{ config, repoName, ... }:

let
  # CENTRALIZED PATH: Derived from the passed repoName
  repoPath = "${config.home.homeDirectory}/${repoName}/modules/home";
in
{
  # Root home files

  # XDG Config files (automatically prefixed with ~/.config/)
  xdg.configFile = {
    "niri".source = config.lib.file.mkOutOfStoreSymlink "${repoPath}/niri";
    "hypr".source = config.lib.file.mkOutOfStoreSymlink "${repoPath}/hyprland";
    "quickshell".source = config.lib.file.mkOutOfStoreSymlink "${repoPath}/quickshell";
  };
}
