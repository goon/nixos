{
  description = "NixOS configuration for desktop";

  # ========== Inputs ==========
  # External dependencies and package sources
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    quickshell.url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
    quickshell.inputs.nixpkgs.follows = "nixpkgs";
    niri.url = "github:niri-wm/niri";
    niri.inputs.nixpkgs.follows = "nixpkgs";

    # Nix-gaming for additional gaming optimizations
    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-gaming.inputs.nixpkgs.follows = "nixpkgs";

    # Affinity creative suite
    affinity-nix.url = "github:mrshmllow/affinity-nix";
    affinity-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Declarative flatpaks for managing Flatpak applications
    flatpaks.url = "github:in-a-dil-emma/declarative-flatpak/latest";

    # Home-Manager for user-level configuration
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Spicetify for Spotify customization
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Treefmt for unified code formatting
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    # nvf for Neovim configuration
    nvf.url = "github:NotAShelf/nvf";
    nvf.inputs.nixpkgs.follows = "nixpkgs";

    # Nixcord for Discord customization
    nixcord.url = "github:FlameFlag/nixcord";
    nixcord.inputs.nixpkgs.follows = "nixpkgs";

    # MangoWM Wayland compositor
    mangowm.url = "github:mangowm/mango";
    mangowm.inputs.nixpkgs.follows = "nixpkgs";
  };

  # System configurations and modules
  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    {
      nixosConfigurations =
        let
          inherit (nixpkgs.lib) nixosSystem;

          # Base modules shared by all hosts
          baseModules = [
            { nixpkgs.config.allowUnfree = true; }
            { nixpkgs.overlays = import ./overlays { inherit inputs; }; }
            {
              _module.args = { inherit inputs; };
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
            inputs.home-manager.nixosModules.default
            inputs.flatpaks.nixosModules.default
            inputs.nvf.nixosModules.default
          ]
          ++ (import ./modules/lib/recursive.nix ./modules);
        in
        {
          desktop = nixosSystem {
            specialArgs = { inherit inputs; };
            system = "x86_64-linux";
            modules = baseModules ++ [ ./host ];
          };
        };

      # Treefmt formatter for nix fmt (multi-system support)
      formatter = nixpkgs.lib.genAttrs [ "x86_64-linux" ] (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          inherit (inputs) treefmt-nix;
        in
        (treefmt-nix.lib.evalModule pkgs ./treefmt.nix).config.build.wrapper
      );

      # Check for nix flake check (multi-system support)
      checks = nixpkgs.lib.genAttrs [ "x86_64-linux" ] (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          inherit (inputs) treefmt-nix;
        in
        {
          formatting = (treefmt-nix.lib.evalModule pkgs ./treefmt.nix).config.build.check self;
        }
      );
    };
}
