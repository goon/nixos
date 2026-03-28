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

    // Track state
    property var activePanel: null
    
    // Track bar geometry for dimming cutouts
    property int barWidth: 0

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
        if (mediaPopout && screenX !== undefined) {
            mediaPopout.anchorX = screenX;
            if (barLeft !== undefined) mediaPopout.anchorMinX = barLeft;
            if (barRight !== undefined) mediaPopout.anchorMaxX = barRight;
        }
        _toggle(mediaPopout);
    }

    function toggleNotificationPopout(screenX, barLeft, barRight) {
        if (notificationPopout && screenX !== undefined) {
            notificationPopout.anchorX = screenX;
            if (barLeft !== undefined) notificationPopout.anchorMinX = barLeft;
            if (barRight !== undefined) notificationPopout.anchorMaxX = barRight;
        }
        _toggle(notificationPopout);
    }

    function toggleSystemPopout(screenX, barLeft, barRight) {
        if (systemPopout && screenX !== undefined) {
            systemPopout.anchorX = screenX;
            if (barLeft !== undefined) systemPopout.anchorMinX = barLeft;
            if (barRight !== undefined) systemPopout.anchorMaxX = barRight;
        }
        _toggle(systemPopout);
    }

    function toggleAudioPopout(screenX, barLeft, barRight) {
        if (audioPopout && screenX !== undefined) {
            audioPopout.anchorX = screenX;
            if (barLeft !== undefined) audioPopout.anchorMinX = barLeft;
            if (barRight !== undefined) audioPopout.anchorMaxX = barRight;
        }
        _toggle(audioPopout);
    }

    function toggleCalendarPopout(screenX, barLeft, barRight) {
        if (calendarPopout && screenX !== undefined) {
            calendarPopout.anchorX = screenX;
            if (barLeft !== undefined) calendarPopout.anchorMinX = barLeft;
            if (barRight !== undefined) calendarPopout.anchorMaxX = barRight;
        }
        _toggle(calendarPopout);
    }

    function togglePowerPopout(screenX, barLeft, barRight) {
        if (powerPopout && screenX !== undefined) {
            powerPopout.anchorX = screenX;
            if (barLeft !== undefined) powerPopout.anchorMinX = barLeft;
            if (barRight !== undefined) powerPopout.anchorMaxX = barRight;
        }
        _toggle(powerPopout);
    }

    // --- UNIFIED SYSTEM CONTROL ---
    function toggleSystemControl(screenX, barLeft, barRight, initialTab) {
        if (systemControlPopout && screenX !== undefined) {
            systemControlPopout.anchorX = screenX;
            if (barLeft !== undefined) systemControlPopout.anchorMinX = barLeft;
            if (barRight !== undefined) systemControlPopout.anchorMaxX = barRight;
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
