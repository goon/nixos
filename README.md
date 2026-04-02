# goon/nixos 


![preview](.github/assets/goonix.png)

**NixOS** configuration designed for a single host featuring flakes and home manager.

> [!IMPORTANT]
> This is my **personal** NixOS configuration, shared for reference and inspiration **NOT** adoption. 
>
> - This configuration is constantly evolving. It is prone to drastic and likely **breaking** changes.
> - Features may be partially implemented or entirely broken.
> - The README and documentation will often times be outdated.
> - I provide **no guarantees** of stability or support.
>
> **If you intend to use any aspect of my configuration, make sure you:**
> 1. Review the code thoroughly.
> 2. Understand what each module does. 
> 3. Adapt it to your specific use case.

## Components 

| Component                                                      | Link                                                                                                                |
| -------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| **Window Manager**                                             | [Niri][Niri]                                                                                                        |
| **Terminal Emulator**                                          | [Kitty][Kitty]                                                                                                      |
| **Display Manager**                                            | [Ly][Ly]                                                                                                            |
| **System Resource Monitor**                                    | [Resources][Resources]                                                                                              |
| **File Manager**                                               | [Yazi][Yazi] & [Nautilus][Nautilus]                                                                                 |
| **Shell**                                                      | Bash & [Starship][Starship]                                                                                         |
| **Media Player**                                               | [Totem][Totem]                                                                                                      |
| **Text Editor**                                                | [Neovim][Neovim]                                                                                                    |
| **Image Viewer**                                               | [Loupe][Loupe]                                                                                                      |
| **Screen Recording**                                           | [OBS][OBS]                                                                                                          |
| **Status Bar / Notifications / Launcher / Wallpaper**          | Made with [Quickshell][Quickshell]

## Structure 

- `flake.nix` & `flake.lock` define the entry point and lock dependencies. 
- `hosts/` contains host specific configuration e.g. `hardware-configuration`. 
- `modules/` houses nix and home manager modules. 
- `treefmt.nix` defines formatting standards for the codebase. 

## Setup

1. **Clone:** 
   ```bash
   nix-shell -p git
   git clone https://github.com/goon/nixos ~/.nixos
   cd ~/.nixos
   ```
   The configuration expects the repository to be located `$HOME/.nixos`

2. **Generate Hardware Configuration:**
   ```bash
   nixos-generate-config --show-hardware-config > hardware-configuration.nix
   ```

3. **Rebuild:**
   ```bash
   sudo nixos-rebuild switch --flake .#desktop 
   ```

4. **Update:**
   ```bash
   sudo nix flake update
   ```

## Links

[Niri]: https://github.com/niri-wm/niri
[Kitty]: https://github.com/kovidv/kitty
[Ly]: https://github.com/nullishzero/ly
[Resources]: https://github.com/nokyan/resources
[Yazi]: https://github.com/sxyazi/yazi
[Nautilus]: https://github.com/GNOME/nautilus
[Starship]: https://github.com/starship/starship
[Totem]: https://github.com/GNOME/totem
[Neovim]: https://github.com/neovim/neovim
[Loupe]: https://github.com/GNOME/loupe
[OBS]: https://github.com/obsproject/obs-studio
[Quickshell]: https://github.com/quickshell-mirror/quickshell

