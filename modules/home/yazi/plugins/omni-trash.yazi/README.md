# omni-trash.yazi

A [Yazi](https://github.com/sxyazi/yazi) plugin for managing your trash across all drives from a single modal interface.

## Features

- **Unified view** — lists trashed files from your home drive and any mounted external drives (`/run/media/…`, `/mnt/…`)
- **Table UI** — shows name, drive, deletion timestamp, and original path
- **Restore** — sends a file back to its original location
- **Purge** — permanently deletes a single item (with confirmation)
- **Empty** — clears all trash across every drive (with confirmation)
- **Non-blocking** — fully async; the Yazi UI stays responsive at all times

## Requirements

- [`trash-cli`](https://github.com/andreafrancia/trash-cli) (`trash-list`, `trash-restore`, `trash-rm`, `trash-empty` must be on `$PATH`)

## Installation

**Via `ya pkg`:**

```sh
ya pkg add goon/omni-trash.yazi
```

**Manual:**

```sh
git clone https://github.com/goon/omni-trash.yazi \
  ~/.config/yazi/plugins/omni-trash.yazi
```

## Setup

Add a keybinding to your `keymap.toml`:

```toml
[[mgr.prepend_keymap]]
on   = "R"
run  = "plugin omni-trash"
desc = "Open Omni Trash"
```

## Keybindings

| Key | Action |
|-----|--------|
| `j` / `↓` | Move down |
| `k` / `↑` | Move up |
| `r` | Restore selected item |
| `d` | Permanently delete selected item |
| `E` | Empty **all** trash (all drives) |
| `q` / `Esc` | Close |

## License

MIT
