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
      # CLI Utilities

      # Development

      # Desktop Apps
      vesktop # Discord
      obsidian # Notes
      antigravity # IDE
      google-chrome # Browser
      nicotine-plus # Soulseek

      # Theming

      # Desktop Environment & WM Tools
      cliphist
      wl-clipboard
      libnotify
    ];
  };
}
