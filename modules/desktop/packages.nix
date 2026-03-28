{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    # ------- Command Line Utilities
    kitty
    fd # Fast file finder
    ripgrep # Grep replacement
    fzf # Fuzzy finder
    zoxide # Smarter cd
    fastfetch
    btop # Resource monitor
    cava # Audio visualizer
    yazi # File Explorer
    starship # Shell prompt
    krabby # Pokemon Sprites 

    # ------- Development Tools
    neovim
    nodejs
    python3
    unzip
    opencode

    # ------- Applications
    vesktop
    obsidian
    obs-studio
    gowall
    antigravity
    google-chrome

    # ------- Theme Tools
    pywal16
    pywalfox-native
  ];
}
