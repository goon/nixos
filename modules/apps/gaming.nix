{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
lib.module config "gaming" false {
  config = {
    imports = [
      inputs.nix-gaming.nixosModules.pipewireLowLatency
    ];

    nixpkgs.overlays = [ inputs.millennium.overlays.default ];

    environment.systemPackages = with pkgs; [
      mangohud
      bolt-launcher
      runelite
      deadlock-mod-manager
    ];

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

    environment.variables = {
      SDL_VIDEODRIVER = lib.mkForce "wayland,x11,windows";
    };

    boot.kernel.sysctl = {
      "vm.max_map_count" = 2147483642;
    };

    nix.settings = {
      substituters = [ "https://nix-gaming.cachix.org" ];
      trusted-public-keys = [ "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" ];
    };
  };

  homeManager = _: {
    home.packages = [ (pkgs.callPackage ../../pkgs/jagex.nix { }) ];
  };
}
