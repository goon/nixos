# omni-trash.yazi

`omni-trash.yazi` is a [Yazi](https://github.com/sxyazi/yazi) plugin for managing your trash across **all drives** from a single, unified interface.

---

## ✨ Features

- **Unified View** — See trashed files from your home drive and all mounted volumes (`/run/media/…`, `/mnt/…`, `/volumes/…`) in one place.
- **Table UI** — Rich display showing filename, drive/volume label, deletion time, and original path.
- **Restore** — Instantly send files back to their original locations with a single keypress.
- **Delete** — Permanently delete items with a safety confirmation.
- **Deep Clean** — Empty your entire trash system across every connected drive.



## 📋 Requirements

- [`trash-cli`](https://github.com/andreafrancia/trash-cli) 
  - **Linux**: `sudo apt/dnf/pacman install trash-cli`
  - **macOS**: `brew install trash-cli`
  

## 📦 Installation

**Via `ya pkg`:**

```sh
ya pkg add goon/omni-trash.yazi
```

**Manual:**

```sh
git clone https://github.com/goon/omni-trash.yazi \
  ~/.config/yazi/plugins/omni-trash.yazi
```

## ⚙️ Setup

Add a keybinding to your `~/.config/yazi/keymap.toml`:

```toml
[[mgr.prepend_keymap]]
on   = "R"
run  = "plugin omni-trash"
desc = "Open Omni Trash"
```

## Keybindings

| Key | Action |
|-----|--------|
| `j` / `↓` | Move cursor down |
| `k` / `↑` | Move cursor up |
| `r` | **Restore** selected item |
| `d` | **Purge** (Permanently delete) |
| `E` | **Empty** all trash (Across all drives) |
| `q` / `Esc` | Close Modal |
