{
  config,
  lib,
  ...
}:

{
  options.module.brave.enable = lib.mkEnableOption "Brave Browser" // {
    default = true;
  };

  config = lib.mkIf config.module.brave.enable {
    home-manager.users.${config._module.args.username} = {
      programs.brave = {
        enable = true;
        extensions = [
          { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
          { id = "jplgfhpmjnbigmhklmmbgecoobifkmpa"; } # Proton VPN
          { id = "ghmbeldphafepmbegfdlkpapadhbakde"; } # Proton Pass
        ];
        commandLineArgs = [
          "--enable-features=UseOzonePlatform"
          "--ozone-platform=wayland"
          "--enable-wayland-ime"
        ];
      };
    };

    # System-level policies to de-bloat Brave and simulate Brave Origin
    environment.etc."brave/policies/managed/policies.json".text = builtins.toJSON {
      "BraveRewardsDisabled" = true;
      "BraveWalletDisabled" = true;
      "BraveAIChatEnabled" = false;
      "BraveVPNDisabled" = true;
      "BraveTalkDisabled" = true;
      "AutofillAddressEnabled" = false;
      "AutofillCreditCardEnabled" = false;
      "PasswordManagerEnabled" = false;
    };
  };
}
