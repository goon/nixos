_:

{
  # Declarative Flatpak configuration
  services.flatpak = {
    enable = true;

    # Add Flathub remote
    remotes = {
      "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    };

    # Install Bottles for managing Windows applications
    packages = [
      "flathub:app/com.usebottles.bottles/x86_64/stable"
      "flathub:app/gg.minion.Minion/x86_64/stable"
    ];

    # Configure Bottles permissions to access secondary drives
    overrides = {
      "com.usebottles.bottles" = {
        Context.filesystems = [ "/mnt/games" ];
      };
    };
  };
}
