# goon/nixos 

**NixOS** configuration designed for a single host featuring flakes and home manager.

This repository reflects my current **NixOS** configuration and is prone to **drastic change** as it constantly evolves.



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
