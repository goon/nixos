# goon/nixos 

<div align="center">

![Commits](https://img.shields.io/github/commit-activity/m/goon/nixos?style=for-the-badge&labelColor=%231e1e2e&color=%23cba6f7) 
![Size](https://img.shields.io/github/repo-size/goon/nixos?style=for-the-badge&labelColor=%231e1e2e&color=%2389b4fa) 
![Stars](https://img.shields.io/github/stars/goon/nixos?style=for-the-badge&labelColor=%231e1e2e&color=%23a6e3a1) 

![preview](assets/goonix.png)

</div>

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
- `treefmt.nix` defines formatting standards for the codebase. 
- `host/` contains host specific configuration e.g. `hardware-configuration`. 
- `modules/` contains nix and home manager modules separated by subfolder. 
- `wallpapers/` collection of wallpapers for your viewing pleasure.

## Setup

1. **Clone:** 
   ```bash
   nix-shell -p git
   git clone --recursive https://github.com/goon/nixos ~/.nixos
   cd ~/.nixos

    # The configuration expects the repository to be located under $HOME/.nixos. 
    # This can be overidden in the modules/options.nix file under "repoName".
    # You should update the "username" in modules/options.nix to match your user.

    # The --recursive flag pulls the quickshell git submodule. 
   ```

2. **Generate Hardware Configuration:**
   ```bash
   nixos-generate-config --show-hardware-config > host/hardware-configuration.nix
   ```

3. **Rebuild:**
   ```bash
   sudo nixos-rebuild switch --flake .#desktop 
   ```

4. **Update:**
   ```bash
   sudo nix flake update
   ```

## Credits

Thank you to the countless Nix OS configurations that I ~~copied~~ learnt from. 

namishh - seniormatt - fufexan - frost-pheonix - anotherhadi - vic - vimjoyer - bad3r - mitchellh - misterio77 - max-baz - gvolpe - librephoenix - sioodmy

Due to my dementia I may have missed many. Regardless, I am thankful.

<!-- Links -->

[Niri]: https://github.com/niri-wm/niri
[Kitty]: https://github.com/kovidgoyal/kitty
[Ly]: https://github.com/fairyglade/ly
[Resources]: https://github.com/nokyan/resources
[Yazi]: https://github.com/sxyazi/yazi
[Nautilus]: https://github.com/GNOME/nautilus
[Starship]: https://github.com/starship/starship
[Totem]: https://github.com/GNOME/totem
[Neovim]: https://github.com/neovim/neovim
[Loupe]: https://github.com/GNOME/loupe
[OBS]: https://github.com/obsproject/obs-studio
[Quickshell]: https://github.com/quickshell-mirror/quickshell
