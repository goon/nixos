{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.module.packages.enable = lib.mkEnableOption "General System Packages" // {
    default = true;
  };

  config = lib.mkIf config.module.packages.enable {

    environment.systemPackages = with pkgs; [
      obsidian # Notes
      antigravity # IDE
      google-chrome # Browser
    ];
  };
}
