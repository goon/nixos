{ pkgs, ... }:

{
  # PipeWire audio server
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;

    # Low-latency for gaming (quantum=64, rate=48000 = ~1.3ms latency)
    lowLatency = {
      enable = true;
      quantum = 64;
      rate = 48000;
    };
  };
  services.pipewire.pulse.enable = true;

  # Real-time kit for audio
  security.rtkit.enable = true;

  # PulseAudio CLI tools
  environment.systemPackages = with pkgs; [
    pulseaudio
  ];

  # MPD Music Player Daemon
  services.mpd = {
    enable = true;
    user = "michael";
    settings = {
      music_directory = "/home/michael/Music";
      audio_output = [
        {
          type = "pulse";
          name = "PipeWire Output";
        }
      ];
    };
  };

  # MPD service needs access to user's PipeWire session
  systemd.services.mpd.environment = {
    XDG_RUNTIME_DIR = "/run/user/1000";
    PULSE_SERVER = "unix:/run/user/1000/pulse/native";
  };
}
