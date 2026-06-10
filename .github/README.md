# goon/nixos 

<div align="center">

![NixOS](https://img.shields.io/badge/NixOS-Config-blue?style=for-the-badge&logo=nixos&logoColor=white&labelColor=%231e1e2e&color=%23cba6f7)
![Stars](https://img.shields.io/github/stars/goon/nixos?style=for-the-badge&labelColor=%231e1e2e&color=%23cba6f7)
![Repo Size](https://img.shields.io/github/repo-size/goon/nixos?style=for-the-badge&labelColor=%231e1e2e&color=%23cba6f7)
![Commits](https://img.shields.io/github/commit-activity/m/goon/nixos?style=for-the-badge&labelColor=%231e1e2e&color=%23cba6c7)

<p align="center"><img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/footers/gray0_ctp_on_line.svg?sanitize=true" /></p>

![preview](assets/goonix.png)

</div>

Oh look, another blazingly mid **NixOS** configuration with a dendritic first design featuring **flakes** and **home manager** with automatic module discovery.

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

## Structure 

- `flake.nix` & `flake.lock` — Define the entry points and locks dependencies. 
- `host/` —  Contains host specific configuration e.g. `hardware-configuration`. 
- `modules/` — Contains nix and home manager modules.
- `scripts/` — Contains various `bash` scripts.
- `wallpapers/` — Collection of wallpapers for your viewing pleasure.

## Modules 

- `modules/commons` — Universal Configurations
- `modules/core` — Device & Hardware Configurations
- `modules/extra` — Software Configurations
- `modules/lib` — Helper Scripts
- `modules/session` — Window Managers & Shell

Every `.nix` file under `modules/` is automatically discovered and imported by `modules/lib/recursive.nix`, preventing the need for manual imports. The importer skips private files prefixed with `_` or `.`, and the `/lib/` directory itself. Most modules follow a **on by default** format. To disable a feature or module on a given host, `module.<name>.enable = false;` can be set.

Hosts are formed by combining the auto discovered modules with host specific overrides in `host/default.nix`. Where the host file serves as a **dendritic dashboard** for enabling hardware support, selecting a window manager and documenting which modules are explicitly enabled or disabled.

## Deployment

1. **Clone:** 
   ```bash
   nix-shell -p git
   git clone --recursive https://github.com/goon/nixos ~/.nixos
   cd ~/.nixos

   ```


- The configuration expects the repository to live in `$HOME/.nixos`
- If your `username` or `repoPath` differs from the defaults, they can be updated in `modules/globals.nix`.
- The `--recursive` flag ensures the `yaks` quickshell submodule is pulled.

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

## License 

This repository is licensed under the **[MIT LICENSE](LICENSE)**. 

<p align="center"><img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/footers/gray0_ctp_on_line.svg?sanitize=true" /></p>