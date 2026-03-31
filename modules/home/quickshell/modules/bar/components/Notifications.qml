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

    Component.onCompleted: PopoutService.notificationsItem = root
    Component.onDestruction: PopoutService.notificationsItem = null

    BaseBlock {
        id: background

        anchors.fill: parent
        paddingHorizontal: Theme.geometry.spacing.dynamicPadding
        paddingVertical: 0
        implicitHeight: Theme.dimensions.barItemHeight
        clickable: true
        hoverEnabled: false
        onClicked: {
            PopoutService.toggleNotificationPopout();
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
