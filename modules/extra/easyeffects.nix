{
  config,
  lib,
  ...
}:

{
  options.module.easyeffects.enable = lib.mkEnableOption "Easy Effects" // {
    default = true;
  };

  config = lib.mkIf config.module.easyeffects.enable {
    home-manager.users.${config._module.args.username} = {
      services.easyeffects.enable = true;
    };
  };
}
