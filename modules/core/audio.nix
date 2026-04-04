{
  config,
  pkgs,
  username,
  ...
}:

{
  # Pipewire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;

    # Low Latency
    lowLatency = {
      enable = true;
      quantum = 64;
      rate = 48000;
    };
  };
  services.pipewire.pulse.enable = true;

  # RT Kit
  security.rtkit.enable = true;

  # Pulse Audio
  environment.systemPackages = with pkgs; [
    pulseaudio
  ];

  # MPD
  services.mpd = {
    enable = true;
    user = username;
    settings = {
      music_directory = "/home/${username}/Music";
      audio_output = [
        {
          type = "pulse";
          name = "PipeWire Output";
        }
      ];
    };
  };
  systemd.services.mpd.environment = {
    XDG_RUNTIME_DIR = "/run/user/${builtins.toString config.users.users.${username}.uid}";
    PULSE_SERVER = "unix:/run/user/${
      builtins.toString config.users.users.${username}.uid
    }/pulse/native";
  };
}
