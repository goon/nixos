{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
lib.module config "gaming" false {
  imports = [
    inputs.nix-gaming.nixosModules.pipewireLowLatency
  ];

  nixpkgs.overlays = [ inputs.millennium.overlays.default ];

  # ========== System Packages ==========
  environment.systemPackages = with pkgs; [
    mangohud
    bolt-launcher
    runelite
  ];

  # ========== Programs & Services ==========
  programs = {
    steam = {
      enable = true;
      package = pkgs.millennium-steam;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };

    gamescope.enable = true;
    gamemode.enable = true;
  };

  # ========== Environment & Hardware tweaks ==========
  environment.variables = {
    SDL_VIDEODRIVER = lib.mkForce "wayland,x11,windows";
  };

  # Kernel performance (vm.max_map_count)
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
  };

  # ========== Binary Caches ==========
  nix.settings = {
    substituters = [ "https://nix-gaming.cachix.org" ];
    trusted-public-keys = [ "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" ];
  };
}
