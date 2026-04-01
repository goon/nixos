{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    # ------- Command Line Utilities

    fd # File Finder
    ripgrep # Improved Grep
    wget # Web Downloads
    curl # Curl

    # ------- Development Tools

    nodejs # Javascript Runtime
    python3 # Python
    go # Go
    unzip

    # ------- Applications

    vesktop # Discord Client
    obsidian # Notes
    obs-studio # Screen Recording & Streaming
    gowall # Wallpaper Themer
    antigravity # Google IDE
    google-chrome # Google Web Browser
    nicotine-plus # GUI client for Soulseek Network

    # ------- Theme Tools

    pywal16 # Colour Palette Generator
    pywalfox-native # Pywalfox Bridge for Firefox
  ];
}
