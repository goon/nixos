# goon/nixos 

<div align="center">
<img src="./assets/nix.png" width="100px">
<br></br>

![NixOS](https://img.shields.io/badge/NixOS-unstable-blue?style=for-the-badge&logo=nixos&logoColor=white&labelColor=%231e1e2e&color=%23cba6f7)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge&labelColor=%231e1e2e&color=%23cba6f7)](/LICENSE)
![Stars](https://img.shields.io/github/stars/goon/nixos?style=for-the-badge&labelColor=%231e1e2e&color=%23cba6f7)
![Commits](https://img.shields.io/github/commit-activity/m/goon/nixos?style=for-the-badge&labelColor=%231e1e2e&color=%23cba6c7)

<p align="center"><img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/footers/gray0_ctp_on_line.svg?sanitize=true" /></p>
</div>

Another **blazingly mid** nix configuration with an overengineered dendritic architecture built on **flakes** and **home manager** with automatic module discovery, powered by **Hyprland**, and held together by hopes, dreams and vibes.

> [!CAUTION]
> This configuration is shared for reference and inspiration, **NOT** adoption.
>
> - This configuration is constantly evolving. It is prone to drastic, **breaking** changes.
> - Features may be partially implemented or entirely broken.
> - The README and documentation will often be outdated.
> - I provide **no guarantees** of stability or support.


## Table of Contents

- [Screenshots](#screenshots)
- [Structure](#structure)
- [Modules](#modules)
- [Formatting](#formatting)
- [Deployment](#deployment)
- [Credits](#credits)
- [License](#license)

## Screenshots 

<div align="center">

![preview](assets/goonix.png)

</div>

## Structure 

- `flake.nix` & `flake.lock` — Define the entry points and locks dependencies. 
- `hosts/` —  Contains host specific configuration.
- `lib/` — Custom abstractions for modules, options and utilities.
- `modules/` — Contains nix and home manager modules.
- `scripts/` — Contains various helper scripts.
- `wallpapers/` — Collection of wallpapers for your viewing pleasure.

## Modules 

- `modules/apps` — Software Configurations
- `modules/core` — Bedrock
- `modules/hardware` — Hardware Configurations
- `modules/session` — Environment Configurations

### The Dendritic Module Engine

To heavily reduce boilerplate traditionally associated with mixing NixOS and Home Manager configurations a custom abstraction engine is used (`lib.module`). 

```nix
{ config, lib, pkgs, ... }:
lib.module config "moduleName" true {
  # 1. System Layer
  config = {
    services.example.enable = true;
    environment.systemPackages = [ pkgs.example-package ];
  };

  # 2. Home Manager Layer
  homeManager = { config, globals, ... }: {
    programs.example = {
      enable = true;
      settings = { ... };
    };
  };
}
```

The `config` and `homeManager` blocks are automatically parsed and natively wired into NixOS and Home Manager under the hood, ensuring that modules remain flat, organised and stripped of boilerplate.

Every `.nix` file under `modules/` is automatically discovered and imported by `lib/recursive.nix`, preventing the need for imports. The importer skips private files prefixed with `_` or `.`. To disable or enable a module on a given host, a boolean toggle e.g. `module.<name> = <true/false>;` can be set.

Hosts are formed by combining the auto discovered modules with host specific overrides in `hosts/<hostname>/default.nix`. Where the host file serves as a **dendritic dashboard** for enabling hardware support, and documenting which modules are explicitly enabled or disabled.

### Profiles 

To avoid manually enabling douzens of individual modules on every host, the configuration uses a high-level profile system defined in `modules/profiles.nix`. 

Profiles bundle related modules together. For example, setting `profile.session = true;` in a host configuration automatically enables the entire desktop session as a cohesive module.

### Globals 

Global options are defined centrally in `modules/globals.nix` under the `globals.` namespace. They allow hosts to share common system settings and user preferences across both NixOS and Home Manager modules.

## Formatting 

The code quality and formatting is enforced via [**treefmt-nix**](https://github.com/numtide/treefmt-nix), utilising three tools. 

- [`nixfmt`](https://github.com/NixOS/nixfmt) — The formatter enforcing the RFC 166 standard, ensuring consistent whitespace, line breaks and attribute ordering. 
- [`deadnix`](https://github.com/astro/deadnix) — Scans for unused `let` bindings, unreferenced function arguments and dead `with` statements.
- [`statix`](https://github.com/nerdypepper/statix) — Analyses expressions for anti-patterns e.g. unused `args`, unnecessary `with` statements and deprecated idioms.

The formatter module at `lib/formatter.nix` is passed through `treefmt-nix`'s `evalModule`, which outputs a combined wrapper binary. The wrapper runs all three tools in sequence.


## Deployment

> [!NOTE]
> These instructions document the bootstrapping process for deploying to a new machine. It is **not** intended as a guide for others to install this configuration. Once again, this configuration is shared for reference and inspiration, **NOT** adoption.

> [!CAUTION]
> The configuration expects the flake to live in `$HOME/.nixos`.
>
> Your username and the location of the flake per host can be modified inside of `hosts/vars.nix`.
>
>**Forgetting to update these values will result in a broken configuration.**

1. **Clone**

```bash
   nix-shell -p git
   git clone --recursive https://github.com/goon/nixos ~/.nixos
   cd ~/.nixos
```

> [!NOTE]
> The `--recursive` flag ensures the `yaks` quickshell submodule is pulled.

2. **Run the Bootstrap Script**

```bash
   ./scripts/bootstrap
```

## Credits

Huge thank you to the countless configurations made public that I ~~copied~~, referenced, learnt from and that inspired me to take my config to the deepest pits of hell.

Both [hlissner](https://github.com/hlissner/dotfiles) and [fufexan](https://github.com/fufexan/dotfiles)'s configurations heavily informed and inspired my own, and many more:

namishh — seniormatt — anotherhadi — vic — vimjoyer — mitchellh — gvolpe — librephoenix 

Due to my dementia I may have missed many. Regardless, I am thankful. 

## License 

This repository is licensed under the **[MIT LICENSE](/LICENSE)**. 

<p align="center"><img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/footers/gray0_ctp_on_line.svg?sanitize=true" /></p>