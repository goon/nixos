import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

Item {
    // Add other IPC targets as needed...

    id: root

    // Launcher
    IpcHandler {
        function toggle() {
            PopoutService.toggleLauncher();
        }

        target: "launcher"
    }

    // Settings
    IpcHandler {
        function toggle() {
            PopoutService.toggleSettings();
        }

        target: "settings"
    }

    // Wallpaper
    IpcHandler {
        function toggle() {
            PopoutService.toggleWallpaper();
        }

        function apply(path: string) {
            Wallpaper.applyWallpaper(path);
        }

        target: "wallpaper"
    }

    // Theme
    IpcHandler {
        function apply(id: string) { ThemeService.setTheme(id); }
        target: "theme"
    }

    IpcHandler {
        function toggle() { PopoutService.toggleMediaPopout(); }
        target: "media"
    }

    IpcHandler {
        function toggle() { PopoutService.toggleNotificationPopout(); }
        target: "notifications"
    }

    IpcHandler {
        function toggle() { PopoutService.toggleSystemPopout(); }
        target: "system"
    }

    IpcHandler {
        function toggle() { PopoutService.toggleAudioPopout(); }
        target: "volume"
    }

    IpcHandler {
        function toggle() { PopoutService.toggleCalendarPopout(); }
        target: "calendar"
    }

    IpcHandler {
        function toggle() { PopoutService.toggleSystemControl(undefined, undefined, undefined, 2); }
        target: "network"
    }

    IpcHandler {
        function toggle() { PopoutService.toggleSystemControl(undefined, undefined, undefined, 1); }
        target: "bluetooth"
    }

    IpcHandler {
        function toggle() { PopoutService.toggleSystemControl(undefined, undefined, undefined, 3); }
        target: "battery"
    }

    IpcHandler {
        function toggle() { PopoutService.toggleSystemControl(undefined, undefined, undefined, 0); }
        target: "power"
    }

    IpcHandler {
        function toggle() { PopoutService.toggleSystemControl(undefined, undefined, undefined, 0); }
        target: "systemcontrol"
    }
}
