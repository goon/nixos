import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import qs

PanelWindow {
    id: popup

    property var notification: null
    property int stackIndex: 0
    property int offset: 0
    property real lifetime: 0
    
    // Decouple data from visual state to allow exit animations
    property var activeNotification: null
    property bool active: false

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.exclusiveZone: -1
    
    // Window must be visible for animations to play
    visible: activeNotification !== null
    color: Theme.colors.transparent
    implicitWidth: Theme.dimensions.toastWidth
    implicitHeight: card.implicitHeight
    screen: Quickshell.screens[0]

    anchors {
        top: true
        right: true
        bottom: false
        left: false
    }

    margins {
        top: Config.notificationToastStackMarginTop + offset
        right: Config.notificationToastMarginRight
    }

    // Logic to handle incoming and outgoing notifications
    onNotificationChanged: {
        if (notification !== null) {
            // New notification arrives
            // First reset state to ensure entrance animation triggers
            active = false;
            activeNotification = notification;
            
            // Brief delay to ensure state change is registered before popping in
            entranceTimer.restart();
        } else if (active) {
            // Data cleared externally (e.g. by manager), trigger exit
            active = false;
        }
    }

    Timer {
        id: entranceTimer
        interval: 16 // ~1 frame
        onTriggered: {
            active = true;
            lifetimeAnim.restart();
        }
    }

    NotificationCard {
        id: card

        anchors.fill: parent
        notification: popup.activeNotification
        progress: popup.lifetime
        showCloseButton: true
        clickable: true
        onClicked: popup.active = false

        // Animations on the card content
        opacity: popup.active ? 1 : 0
        scale: popup.active ? 1 : 0.8

        Behavior on opacity {
            BaseAnimation {
                speed: "normal"
                easing.type: Easing.OutQuint
                onRunningChanged: {
                    if (!running && !popup.active) {
                        // Cleanup after fade out
                        popup.activeNotification = null;
                        popup.notification = null;
                        popup.lifetime = 0;
                    }
                }
            }
        }

        Behavior on scale {
            BaseAnimation {
                speed: "normal"
                easing.type: Easing.OutBack
            }
        }

        onCloseClicked: {
            popup.active = false;
        }
    }

    BaseAnimation {
        id: lifetimeAnim
        from: 0
        to: 1
        duration: Config.notificationTimeout
        target: popup
        property: "lifetime"
        easing.type: Easing.Linear
        onFinished: {
            expireTimer.restart();
        }
    }

    Timer {
        id: expireTimer
        interval: 1000 // 1 second delay after progress bar fills
        onTriggered: popup.active = false
    }

    Behavior on margins.top {
        BaseAnimation {
            easing.type: Easing.OutCubic
        }
    }
}
