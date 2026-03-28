_:

{
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.auto-optimise-store = true;
  nix.settings.warn-dirty = false;
  nix.settings.trusted-public-keys = [
    "niri.cachix.org-1:Wv0NxOcoZsSsIa5NbZaf1QjZbmhbNnsCf7cH8H1HGyc="
  ];

  nix.gc.automatic = false;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.dates = "weekly";
    clean.extraArgs = "--keep 3";
  };
}
