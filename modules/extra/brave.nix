{
  config,
  lib,
  ...
}:

lib.module config "brave" true {
    home-manager.sharedModules = [
      {
        programs.brave = {
          enable = true;
          extensions = [
            { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
            { id = "jplgfhpmjnbigmhklmmbgecoobifkmpa"; } # Proton VPN
            { id = "ghmbeldphafepmbegfdlkpapadhbakde"; } # Proton Pass
            { id = "cnjifjpddelmedmihgijeibhnjfabmlf"; } # Obsidian Web Clipper
          ];
          commandLineArgs = [
            "--enable-features=UseOzonePlatform"
            "--ozone-platform=wayland"
            "--enable-wayland-ime"
          ];
        };
      }
    ];

    # Debloat
    environment.etc."brave/policies/managed/policies.json".text = builtins.toJSON {
      "BraveRewardsDisabled" = true;
      "BraveWalletDisabled" = true;
      "BraveAIChatEnabled" = false;
      "BraveVPNDisabled" = true;
      "BraveTalkDisabled" = true;
      "AutofillAddressEnabled" = false;
      "AutofillCreditCardEnabled" = false;
      "PasswordManagerEnabled" = false;
    };}