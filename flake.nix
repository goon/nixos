{
  description = "NixOS configuration for desktop";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    quickshell.url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
    quickshell.inputs.nixpkgs.follows = "nixpkgs";

    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-gaming.inputs.nixpkgs.follows = "nixpkgs";

    affinity-nix.url = "github:mrshmllow/affinity-nix";
    affinity-nix.inputs.nixpkgs.follows = "nixpkgs";

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    nvf.url = "github:NotAShelf/nvf";
    nvf.inputs.nixpkgs.follows = "nixpkgs";

    nixcord.url = "github:FlameFlag/nixcord";
    nixcord.inputs.nixpkgs.follows = "nixpkgs";

    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
    millennium.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    {
      nixosConfigurations =
        let
          extendedLib = import ./lib {
            inherit inputs;
            inherit (nixpkgs) lib;
          };

          baseModules = [
            (
              { config, ... }:
              {
                home-manager.extraSpecialArgs = {
                  inherit inputs;
                  inherit (config) globals;
                };
              }
            )
            inputs.home-manager.nixosModules.default
            inputs.nix-flatpak.nixosModules.nix-flatpak
          ]
          ++ (import ./lib/recursive.nix ./modules);
        in
        extendedLib.mkHosts ./hosts {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            lib = extendedLib;
          };
          inherit baseModules;
        };

      formatter = nixpkgs.lib.genAttrs [ "x86_64-linux" ] (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          inherit (inputs) treefmt-nix;
        in
        (treefmt-nix.lib.evalModule pkgs ./lib/formatter.nix).config.build.wrapper
      );

      checks = nixpkgs.lib.genAttrs [ "x86_64-linux" ] (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          inherit (inputs) treefmt-nix;
        in
        {
          formatting = (treefmt-nix.lib.evalModule pkgs ./lib/formatter.nix).config.build.check self;
        }
      );
    };
}
