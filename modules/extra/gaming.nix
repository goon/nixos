{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib) mkIf mkForce mkEnableOption;
in
{
  imports = [
    inputs.nix-gaming.nixosModules.pipewireLowLatency
  ];

  options.module.gaming.enable =
    mkEnableOption "Gaming optimizations and tools (Steam, Gamescope, Gamemode)"
    // {
      default = true;
    };

  config = mkIf config.module.gaming.enable {
    # ========== System Packages ==========
    environment.systemPackages = with pkgs; [
      mangohud
      bolt-launcher
    ];

    # ========== Programs & Services ==========
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

    # ========== Environment & Hardware tweaks ==========
    environment.variables = {
      SDL_VIDEODRIVER = mkForce "wayland,x11,windows";
    };

    # Steam Networking
    networking.firewall.allowedTCPPorts = [
      27036
      27037
    ];
    networking.firewall.allowedUDPPorts = [
      27031
      27036
    ];

    # Kernel performance (vm.max_map_count)
    boot.kernel.sysctl = {
      "vm.max_map_count" = 2147483642;
    };

    # ========== Binary Caches ==========
    nix.settings = {
      substituters = [ "https://nix-gaming.cachix.org" ];
      trusted-public-keys = [ "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" ];
    };
  };
}
