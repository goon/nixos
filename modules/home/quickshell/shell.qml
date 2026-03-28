import QtQuick
//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import qs
import qs.services

ShellRoot {
    // Instantiate Stats service for background tracking
    property var _stats: Stats
    property var _gowall: Gowall

    objectName: "shellRoot"
    Component.onCompleted: {
        PopoutService.launcher = launcher;
        PopoutService.settings = settings;
        PopoutService.mediaPopout = mediaPopout;
        PopoutService.notificationPopout = notificationPopout;
        PopoutService.notificationManager = notificationService;
        PopoutService.systemPopout = systemPopout;
        PopoutService.audioPopout = audioPopout;
        PopoutService.calendarPopout = calendarPopout;
        PopoutService.systemControlPopout = systemControlPopout;
    }

    Commander {
        id: commander
    }

    NotificationServer {
        id: notificationServer
    }

    NotificationManager {
        id: notificationService

        notificationServer: notificationServer
    }

    // Windows / Overlays
    Launcher {
        id: launcher
    }

    Settings {
        id: settings
    }

    MediaPopout {
        id: mediaPopout
    }

    SystemControlPopout {
        id: systemControlPopout
    }

    NotificationPopout {
        id: notificationPopout
        notificationManager: notificationService
    }

    SystemPopout {
        id: systemPopout
    }

    AudioPopout {
        id: audioPopout
    }

    CalendarPopout {
        id: calendarPopout
    }


    Instantiator {
        model: Quickshell.screens

        WallpaperBackground {
            screen: modelData
        }

    }

    Instantiator {
        model: Quickshell.screens

        Bar {
            screen: modelData
        }
    }

}
