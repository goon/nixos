{ config, repoName, ... }:

let
  # CENTRALIZED PATH: Derived from the passed repoName
  repoPath = "${config.home.homeDirectory}/${repoName}/modules/home";
in
{
  # Root home files
  home.file.".bashrc".source = config.lib.file.mkOutOfStoreSymlink "${repoPath}/bash/.bashrc";

  # XDG Config files (automatically prefixed with ~/.config/)
  xdg.configFile = {
    "kitty".source = config.lib.file.mkOutOfStoreSymlink "${repoPath}/kitty";
    "niri".source = config.lib.file.mkOutOfStoreSymlink "${repoPath}/niri";
    "fastfetch".source = config.lib.file.mkOutOfStoreSymlink "${repoPath}/fastfetch";
    "quickshell".source = config.lib.file.mkOutOfStoreSymlink "${repoPath}/quickshell";
    "starship".source = config.lib.file.mkOutOfStoreSymlink "${repoPath}/starship";
    "nvim".source = config.lib.file.mkOutOfStoreSymlink "${repoPath}/nvim";
    "yazi".source = config.lib.file.mkOutOfStoreSymlink "${repoPath}/yazi";
    "mpv".source = config.lib.file.mkOutOfStoreSymlink "${repoPath}/mpv";
    "opencode/opencode.json".source =
      config.lib.file.mkOutOfStoreSymlink "${repoPath}/opencode/opencode.json";
  };
}
