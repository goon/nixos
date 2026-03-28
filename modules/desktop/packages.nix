{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    # ------- Command Line Utilities

    kitty                     # Terminal Emulator 
    fd                        # File Finder 
    ripgrep                   # Improved Grep 
    fzf                       # Fuzzy Finder
    zoxide                    # cd 
    fastfetch                 # System Info 
    btop                      # Resource Monitor 
    cava                      # Audio Visualizer
    yazi                      # File Explorer
    starship                  # Shell Prompt 
    krabby                    # Pokemon Sprites
    wget                      # Web Downloads 
    curl                      # Curl 
    trash-cli                 # CLI Trash Manager

    # ------- Development Tools

    neovim                    # Terminal Editor 
    nodejs                    # Javascript Runtime 
    python3                   # Python 
    unzip                     
    opencode                  # Opencode TUI

    # ------- Applications

    vesktop                   # Discord Client 
    obsidian                  # Notes 
    obs-studio                # Screen Recording & Streaming 
    gowall                    # Wallpaper Themer 
    antigravity               # Google IDE 
    google-chrome             # Google Web Browser
    pear-desktop              # Youtube Music Wrapper (Electron) 

    # ------- Theme Tools

    pywal16                   # Colour Palette Generator 
    pywalfox-native           # Pywalfox Bridge for Firefox 
  ];
}
