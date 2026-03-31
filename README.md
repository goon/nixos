# goon/nixos 


![preview](.github/assets/goonix.png)

**NixOS** configuration designed for a single host featuring flakes and home manager.

This repository reflects my current **NixOS** configuration and is prone to **drastic change** as it constantly evolves.

## Features 

- **OS** - Nix OS 
- **WM** - Niri 
- **Shell** - Bash 
- **Term** - Kitty 
- **Editor** - Neovim 

## Structure 

- `flake.nix` & `flake.lock` define the entry point and lock dependencies. 
- `hosts/` contains host specific configuration e.g. `hardware-configuration`. 
- `modules/` houses nix and home manager modules. 
- `treefmt.nix` defines formatting standards for the codebase. 

## Setup

1. **Clone:** 
   ```bash
   git clone https://github.com/goon/nixos ~/.nixos
   cd ~/.nixos
   ```

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
