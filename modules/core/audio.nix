{
  config,
  pkgs,
  username,
  ...
}:

{
  services = {
    # Pipewire
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;

      # Low Latency
      lowLatency = {
        enable = true;
        quantum = 64;
        rate = 48000;
      };
    };

    # MPD
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

  # RT Kit
  security.rtkit.enable = true;

  # Pulse Audio
  environment.systemPackages = with pkgs; [
    pulseaudio
  ];

  systemd.services.mpd.environment = {
    XDG_RUNTIME_DIR = "/run/user/${builtins.toString config.users.users.${username}.uid}";
    PULSE_SERVER = "unix:/run/user/${
      builtins.toString config.users.users.${username}.uid
    }/pulse/native";
  };
}
