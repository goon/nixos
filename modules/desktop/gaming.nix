{ pkgs, lib, ... }:

{
  # Gaming packages
  environment.systemPackages = with pkgs; [
    mangohud
    bolt-launcher
  ];

  # Steam configuration
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    protontricks.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  programs.gamescope.enable = true;
  programs.gamemode.enable = true;

  # SDL video driver configuration (fixes SDL games on NixOS)
  environment.variables = {
    SDL_VIDEODRIVER = lib.mkForce "wayland,x11,windows";
  };

  # Firewall ports for Steam
  networking.firewall.allowedTCPPorts = [
    27036
    27037
  ];
  networking.firewall.allowedUDPPorts = [
    27031
    27036
  ];

  # Kernel parameter for memory-intensive games
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
  };

  # nix-gaming binary cache (faster builds)
  nix.settings = {
    substituters = [ "https://nix-gaming.cachix.org" ];
    trusted-public-keys = [ "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" ];
  };
}
