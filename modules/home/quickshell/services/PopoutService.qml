import QtQuick
import Quickshell
import qs
pragma Singleton

QtObject {
    id: root

    // Pointers to the various panels injected by shell.qml
    property var launcher: null
    property var settings: null
    property var mediaPopout: null
    property var systemPopout: null
    property var audioPopout: null
    property var calendarPopout: null
    property var notificationPopout: null
    property var notificationManager: null
    property var powerPopout: null
    property var systemControlPopout: null

    // Bar component references for automatic anchoring
    property Item launcherItem: null
    property Item systemResourcesItem: null
    property Item systemControlItem: null
    property Item volumeItem: null
    property Item notificationsItem: null
    property Item nowPlayingItem: null
    property Item clockItem: null

    // Track state
    property var activePanel: null
    
    // Track bar geometry for dimming cutouts
    property int barWidth: 0

    function _getCoordinatesFromItem(item) {
        if (!item) return undefined;
        
        try {
            var posInWindow = item.mapToItem(null, item.width / 2, 0);
            var topParent = item;
            while (topParent.parent) topParent = topParent.parent;
            var barWidth = topParent.width;

            var screen = Quickshell.screens[0];
            var barScreenX;
            if (Preferences.barFitToContent) {
                barScreenX = (screen.width - barWidth) / 2;
            } else {
                barScreenX = Preferences.barMarginSide;
            }

            return {
                screenX: barScreenX + posInWindow.x,
                barLeft: barScreenX,
                barRight: barScreenX + barWidth
            };
        } catch (e) {
            return undefined;
        }
    }

    function toggleLauncher() {
        _toggle(launcher);
    }

    function toggleWallpaper() {
        if (!launcher)
            return ;

        // If another panel is open (and it's not the launcher), close it
        if (activePanel && activePanel !== launcher)
            activePanel.close();

        // Open/Toggle logic
        if (launcher.panelState !== "Open" && launcher.panelState !== "Opening") {
            launcher.open();
            activePanel = launcher;
        }
        launcher.switchToTab(2);
    }

    function toggleSettings() {
        _toggle(settings);
    }

    function toggleMediaPopout(screenX, barLeft, barRight) {
        if (screenX === undefined && nowPlayingItem) {
            var coords = _getCoordinatesFromItem(nowPlayingItem);
            if (coords) {
                screenX = coords.screenX;
                barLeft = coords.barLeft;
                barRight = coords.barRight;
            }
        }

        if (mediaPopout) {
            mediaPopout.anchorX = (screenX !== undefined) ? screenX : -1;
            if (barLeft !== undefined) mediaPopout.anchorMinX = barLeft;
            if (barRight !== undefined) mediaPopout.anchorMaxX = barRight;
        }
        _toggle(mediaPopout);
    }

    function toggleNotificationPopout(screenX, barLeft, barRight) {
        if (screenX === undefined && notificationsItem) {
            var coords = _getCoordinatesFromItem(notificationsItem);
            if (coords) {
                screenX = coords.screenX;
                barLeft = coords.barLeft;
                barRight = coords.barRight;
            }
        }

        if (notificationPopout) {
            notificationPopout.anchorX = (screenX !== undefined) ? screenX : -1;
            if (barLeft !== undefined) notificationPopout.anchorMinX = barLeft;
            if (barRight !== undefined) notificationPopout.anchorMaxX = barRight;
        }
        _toggle(notificationPopout);
    }

    function toggleSystemPopout(screenX, barLeft, barRight) {
        if (screenX === undefined && systemResourcesItem) {
            var coords = _getCoordinatesFromItem(systemResourcesItem);
            if (coords) {
                screenX = coords.screenX;
                barLeft = coords.barLeft;
                barRight = coords.barRight;
            }
        }

        if (systemPopout) {
            systemPopout.anchorX = (screenX !== undefined) ? screenX : -1;
            if (barLeft !== undefined) systemPopout.anchorMinX = barLeft;
            if (barRight !== undefined) systemPopout.anchorMaxX = barRight;
        }
        _toggle(systemPopout);
    }

    function toggleAudioPopout(screenX, barLeft, barRight) {
        if (screenX === undefined && volumeItem) {
            var coords = _getCoordinatesFromItem(volumeItem);
            if (coords) {
                screenX = coords.screenX;
                barLeft = coords.barLeft;
                barRight = coords.barRight;
            }
        }

        if (audioPopout) {
            audioPopout.anchorX = (screenX !== undefined) ? screenX : -1;
            if (barLeft !== undefined) audioPopout.anchorMinX = barLeft;
            if (barRight !== undefined) audioPopout.anchorMaxX = barRight;
        }
        _toggle(audioPopout);
    }

    function toggleCalendarPopout(screenX, barLeft, barRight) {
        if (screenX === undefined && clockItem) {
            var coords = _getCoordinatesFromItem(clockItem);
            if (coords) {
                screenX = coords.screenX;
                barLeft = coords.barLeft;
                barRight = coords.barRight;
            }
        }

        if (calendarPopout) {
            calendarPopout.anchorX = (screenX !== undefined) ? screenX : -1;
            if (barLeft !== undefined) calendarPopout.anchorMinX = barLeft;
            if (barRight !== undefined) calendarPopout.anchorMaxX = barRight;
        }
        _toggle(calendarPopout);
    }

    function togglePowerPopout(screenX, barLeft, barRight) {
        if (screenX === undefined && systemControlItem) {
            var coords = _getCoordinatesFromItem(systemControlItem);
            if (coords) {
                screenX = coords.screenX;
                barLeft = coords.barLeft;
                barRight = coords.barRight;
            }
        }

        if (powerPopout) {
            powerPopout.anchorX = (screenX !== undefined) ? screenX : -1;
            if (barLeft !== undefined) powerPopout.anchorMinX = barLeft;
            if (barRight !== undefined) powerPopout.anchorMaxX = barRight;
        }
        _toggle(powerPopout);
    }

    // --- UNIFIED SYSTEM CONTROL ---
    function toggleSystemControl(screenX, barLeft, barRight, initialTab) {
        if (screenX === undefined && systemControlItem) {
            var coords = _getCoordinatesFromItem(systemControlItem);
            if (coords) {
                screenX = coords.screenX;
                barLeft = coords.barLeft;
                barRight = coords.barRight;
            }
        }

        if (systemControlPopout) {
            systemControlPopout.anchorX = (screenX !== undefined) ? screenX : -1;
            systemControlPopout.anchorMinX = (barLeft !== undefined) ? barLeft : -1;
            systemControlPopout.anchorMaxX = (barRight !== undefined) ? barRight : -1;
        }
        
        // If we are opening the panel, set the tab
        if (systemControlPopout && systemControlPopout.panelState !== "Open" && systemControlPopout.panelState !== "Opening") {
            if (initialTab !== undefined) {
                systemControlPopout.switchToTab(initialTab);
            }
        }
        
        _toggle(systemControlPopout);
    }

    // Generic toggle for any tracked panel
    function _toggle(panel) {
        if (!panel)
            return ;

        // Close any open tray menu whenever a bar popout is toggled
        TrayService.closeCurrentMenu();

        // If this one is currently active, just toggle it
        if (activePanel === panel) {
            panel.toggle();
            // If we are toggling the active panel, it is closing.
            activePanel = null;
            return ;
        }
        // If another panel is open, close it first
        if (activePanel)
            activePanel.close();

        // Open the new panel
        panel.toggle();
        activePanel = panel;
    }

    function closeAll() {
        if (activePanel) {
            activePanel.close();
            activePanel = null;
        }
    }
}
