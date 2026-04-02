{ username, pkgs, ... }:

{
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "video"
      "render"
      "i2c"
    ];
    shell = pkgs.zsh;
  };

  # XDG Variables
  environment.sessionVariables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_STATE_HOME = "$HOME/.local/state";
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "firefox";
  };
}
