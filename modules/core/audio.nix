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
}
