{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.module.localsend.enable = lib.mkEnableOption "LocalSend" // {
    default = true;
  };

  config = lib.mkIf config.module.localsend.enable {
    programs.localsend = {
      enable = true;
      openFirewall = true;
    };
  };
}
