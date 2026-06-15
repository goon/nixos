{
  config,
  lib,
  ...
}:

lib.module config "easyeffects" true {
    home-manager.sharedModules = [
      {
        services.easyeffects.enable = true;
      }
    ];}