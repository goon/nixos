{ username, ... }:

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
}
