{
  # Enable Ly display manager
  services.displayManager.ly = {
    enable = true;
    settings = {
      # Customization options
      animate = true;
      animation = "doom";
      bg = 0; # Use Mocha Base (#1e1e2e)
      fg = 7; # Use Mocha Subtext1 (#bac2de)
    };
  };

  # Set Catppuccin Mocha colors for the TTY
  console.colors = [
    "1e1e2e" # 0: Base
    "f38ba8" # 1: Red
    "a6e3a1" # 2: Green
    "f9e2af" # 3: Yellow
    "89b4fa" # 4: Blue
    "f5c2e7" # 5: Pink
    "94e2d5" # 6: Teal
    "bac2de" # 7: Subtext1
    "585b70" # 8: Surface2
    "f38ba8" # 9: Red
    "a6e3a1" # 10: Green
    "f9e2af" # 11: Yellow
    "89b4fa" # 12: Blue
    "f5c2e7" # 13: Pink
    "94e2d5" # 14: Teal
    "a6adc8" # 15: Subtext0
  ];
}
