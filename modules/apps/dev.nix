{
  config,
  lib,
  pkgs,
  ...
}:

lib.module config "dev" false {
  userPkgs = with pkgs; [
    antigravity
  ];

  home = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.vscodium = {
      enable = true;
      profiles.default = {
        extensions =
          with pkgs.vscode-extensions;
          [
            jnoortheen.nix-ide
          ]
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
              name = "qt-core";
              publisher = "TheQtCompany";
              version = "1.15.0";
              sha256 = "0iip8hl9yplv1jq0167xyg0jzvfk4j0qqyxjrjk2fbr8jv3xymqr";
            }
            {
              name = "qt-qml";
              publisher = "TheQtCompany";
              version = "1.15.0";
              sha256 = "1nnx5w03clg3qml9kqm89pp5na20907ra413g99ilqcfdshjf8jj";
            }
            {
              name = "opencode";
              publisher = "sst-dev";
              version = "0.0.13";
              sha256 = "1m301j2qbym3j2qnck76jyxakca3h1qiybc2r7wy7z11m98mg9z9";
            }
          ];
      };
    };
  };
}
