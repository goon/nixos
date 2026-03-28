import QtQuick
import Quickshell
import qs
import qs.services

pragma Singleton

Item {
    id: root

    // Application metadata for theming
    readonly property var applications: [
        {
            "id": "gtk",
            "name": "GTK",
            "binary": "command -v gsettings",
            "script": "gtk.sh",
            "path": "~/.config/gtk-4.0"
        },
        {
            "id": "kitty",
            "name": "Kitty",
            "binary": "command -v kitty",
            "script": "kitty.sh",
            "path": "~/.config/kitty"
        },
        {
            "id": "nvim",
            "name": "Neovim",
            "binary": "command -v nvim",
            "script": "nvim.sh",
            "path": "~/.config/nvim"
        },
        {
            "id": "obsidian",
            "name": "Obsidian",
            "binary": "command -v obsidian || flatpak info md.obsidian.Obsidian",
            "script": "obsidian.sh",
            "path": "Vaults/.obsidian/snippets"
        },
        {
            "id": "vesktop",
            "name": "Vesktop",
            "binary": "command -v vesktop || flatpak info dev.vencord.Vesktop",
            "script": "vesktop.sh",
            "path": "~/.config/vesktop/themes"
        },
        {
            "id": "firefox",
            "name": "Firefox",
            "binary": "command -v pywalfox",
            "script": "firefox.sh",
            "path": "~/.cache/quickshell/themes"
        },
        {
            "id": "steam",
            "name": "Steam",
            "binary": "command -v steam",
            "script": "steam.sh",
            "path": "~/.config/millenium"
        },
        {
            "id": "gowall",
            "name": "Gowall",
            "binary": "command -v gowall",
            "script": "gowall.sh",
            "path": "Wallpaper Gen"
        },
        {
            "id": "qt6ct",
            "name": "Qt6ct",
            "binary": "command -v qt6ct",
            "script": "qt6ct.sh",
            "path": "~/.config/qt6ct"
        }
    ]

    function getApp(id) {
        for (var i = 0; i < applications.length; i++) {
            if (applications[i].id === id) return applications[i];
        }
        return null;
    }
}
