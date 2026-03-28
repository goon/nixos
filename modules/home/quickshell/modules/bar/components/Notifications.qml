import QtQuick
import QtQuick.Layouts
import Quickshell
import qs

Item {
    id: root

    readonly property bool dndActive: Preferences.notificationMode === 1
    readonly property bool hasUnread: PopoutService.notificationManager ? PopoutService.notificationManager.unreadCount > 0 : false

    Layout.alignment: Qt.AlignVCenter
    Layout.fillWidth: false
    implicitWidth: background.implicitWidth
    implicitHeight: Theme.dimensions.barItemHeight

    BaseBlock {
        id: background

        anchors.fill: parent
        paddingHorizontal: Theme.geometry.spacing.dynamicPadding
        paddingVertical: 0
        implicitHeight: Theme.dimensions.barItemHeight
        clickable: true
        hoverEnabled: false
        onClicked: {
            // Calculate position for popout anchoring
            var posInWindow = root.mapToItem(null, root.width / 2, 0);
            var topParent = root;
            while (topParent.parent)topParent = topParent.parent
            var barWidth = topParent.width;
            var screen = Quickshell.screens[0];
            var barScreenX;
            if (Preferences.barFitToContent)
                barScreenX = (screen.width - barWidth) / 2;
            else
                barScreenX = Preferences.barMarginSide;
            var screenX = barScreenX + posInWindow.x;
            PopoutService.toggleNotificationPopout(screenX, barScreenX, barScreenX + barWidth);
        }
        onRightClicked: {
            Preferences.notificationMode = root.dndActive ? 0 : 1;
        }

        BaseIcon {
            id: icon

            Layout.alignment: Qt.AlignCenter
            icon: {
                if (root.dndActive)
                    return "notifications_off";

                if (root.hasUnread)
                    return "notifications_unread";

                return "notifications";
            }
            size: Theme.dimensions.iconBase
            color: background.containsMouse ? Theme.colors.primary : (root.dndActive ? Theme.colors.error : Theme.colors.text)
        }

    }

}
