{ username, config, ... }:

{
  users.users.${username} = {
    isNormalUser = true;
    uid = 1000;
    description = username;
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "video"
      "render"
      "i2c"
    ];
  };

  # XDG Variables (Baseline)
  environment.sessionVariables = {
    XDG_CONFIG_HOME = config.globals.paths.config;
    XDG_DATA_HOME = config.globals.paths.data;
    XDG_CACHE_HOME = config.globals.paths.cache;
    XDG_STATE_HOME = config.globals.paths.state;
  };
}
