{
  config,
  username,
  ...
}:
{
  services = {
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };

    mpd = {
      enable = true;
      user = username;
      settings = {
        music_directory = "${config.globals.paths.home}/Music";
        audio_output = [
          {
            type = "pulse";
            name = "PipeWire Output";
          }
        ];
      };
    };
  };

  security.rtkit.enable = true;

  systemd.services.mpd.environment = {
    XDG_RUNTIME_DIR = "/run/user/${builtins.toString config.users.users.${username}.uid}";
    PULSE_SERVER = "unix:/run/user/${
      builtins.toString config.users.users.${username}.uid
    }/pulse/native";
  };
}
