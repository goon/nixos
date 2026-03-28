{
  description = "NixOS configuration for desktop";

  # ========== Inputs ==========
  # External dependencies and package sources
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    quickshell.url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
    quickshell.inputs.nixpkgs.follows = "nixpkgs";
    niri.url = "github:niri-wm/niri?ref=wip/branch";
    niri.inputs.nixpkgs.follows = "nixpkgs";

    # Nix-gaming for additional gaming optimizations
    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-gaming.inputs.nixpkgs.follows = "nixpkgs";

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

    # Void SDDM Theme (no flake, just a plain git repo)
    voidsddm = {
      type = "github";
      owner = "talyamm";
      repo = "VoidSDDM";
      flake = false;
    };
  };

  # ========== Outputs ==========
  # System configurations and modules
  outputs =
    inputs@{
      self,
      nixpkgs,
      treefmt-nix,
      ...
    }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      fonts = {
        sansSerif = "Outfit";
        monospace = "Kode Mono";
      };
      user = "michael";
      repoName = ".nixos";
    in
    {
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs fonts user repoName; };
        modules = [
          # Reproducibility: Isolate from local ~/.config/nixpkgs/
          { nixpkgs.config.allowUnfree = true; }
          { nixpkgs.overlays = [ ]; }
          { home-manager.extraSpecialArgs = { inherit fonts user repoName; }; }
          inputs.home-manager.nixosModules.default
          inputs.flatpaks.nixosModules.default
          inputs.nix-gaming.nixosModules.pipewireLowLatency
          ./hosts/desktop
        ];
      };

      # Treefmt formatter for nix fmt (multi-system support)
      formatter = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        (treefmt-nix.lib.evalModule pkgs ./treefmt.nix).config.build.wrapper
      );

      # Check for nix flake check (multi-system support)
      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          formatting = (treefmt-nix.lib.evalModule pkgs ./treefmt.nix).config.build.check self;
        }
      );
    };
}
