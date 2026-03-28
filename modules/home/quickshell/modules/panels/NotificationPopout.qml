import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import qs

BasePopoutWindow {
    id: root

    property var notificationManager: null
    property var expandedStates: ({
    })
    property var groupedModel: []

    fixedWidth: 550
    panelNamespace: "quickshell:notification-popout"

    body: ScrollView {
        id: mainScroll

        implicitWidth: 400
        implicitHeight: Math.min(800, mainContent.implicitHeight)
        contentWidth: availableWidth
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        ColumnLayout {
            id: mainContent

            property var notificationManager: root.notificationManager
            property int notifCount: notificationManager ? notificationManager.notificationHistory.count : 0

            function updateGroupedModel() {
                if (!notificationManager) {
                    root.groupedModel = [];
                    return ;
                }
                const history = notificationManager.notificationHistory;
                const groups = {
                };
                const result = [];
                for (let i = 0; i < history.count; i++) {
                    const item = history.get(i);
                    const appName = item.modelData.appName || "Unknown";
                    if (!groups[appName]) {
                        groups[appName] = {
                            "appName": appName,
                            "notifications": [],
                            "latest": item.receivedAt
                        };
                        result.push(groups[appName]);
                    }
                    groups[appName].notifications.push(item);
                }
                root.groupedModel = result;
            }

            width: parent.width
            spacing: Theme.geometry.spacing.large
            Component.onCompleted: updateGroupedModel()

            Connections {
                function onCountChanged() {
                    mainContent.updateGroupedModel();
                }

                target: mainContent.notificationManager ? mainContent.notificationManager.notificationHistory : null
            }

            BaseBlock {
                Layout.fillWidth: true
                title: "Notifications (" + mainContent.notifCount + ")"

                headerItem: RowLayout {
                    spacing: Theme.geometry.spacing.small

                    BaseButton {
                        icon: Preferences.notificationMode === 1 ? "notifications_off" : "notifications"
                        iconColor: (Preferences.notificationMode === 1 && !containsMouse) ? Theme.colors.error : (containsMouse ? Theme.colors.primary : Theme.colors.text)
                        size: Theme.dimensions.iconMedium
                        normalColor: Theme.colors.transparent
                        hoverColor: Theme.alpha(Theme.colors.error, 0.1)
                        onClicked: Preferences.notificationMode = (Preferences.notificationMode + 1) % 2
                    }

                    BaseButton {
                        icon: "delete_sweep"
                        size: Theme.dimensions.iconMedium
                        normalColor: Theme.colors.transparent
                        hoverColor: Theme.alpha(Theme.colors.error, 0.1)
                        onClicked: {
                            if (mainContent.notificationManager) {
                                const model = mainContent.notificationManager.notificationHistory;
                                for (let i = model.count - 1; i >= 0; i--) {
                                    let notif = model.get(i).modelData;
                                    if (notif)
                                        notif.dismiss();
                                }
                            }
                        }
                        enabled: mainContent.notificationManager && mainContent.notificationManager.notificationHistory.count > 0
                        opacity: enabled ? 1 : 0.3
                    }
                }

                // Notifications List
                ListView {
                    id: list

                    Layout.fillWidth: true
                    implicitHeight: contentHeight
                    model: root.groupedModel
                    spacing: Theme.geometry.spacing.medium
                    interactive: false

                    delegate: Column {
                        id: groupDelegate

                        property var groupData: modelData
                        property bool isStack: groupData.notifications.length > 1
                        property bool expanded: root.expandedStates[groupData.appName] === true

                        width: ListView.view.width
                        spacing: Theme.geometry.spacing.small // Tighter gap within a group stack

                        // Stack/Header
                        Item {
                            width: parent.width
                            height: headerCard.implicitHeight + (isStack && !expanded ? 12 : 0)

                            MouseArea {
                                anchors.fill: parent
                                enabled: isStack
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: {
                                    var states = root.expandedStates;
                                    states[groupData.appName] = !groupDelegate.expanded;
                                    root.expandedStates = Object.assign({}, states);
                                }
                            }

                            // Stack Background (Shadow/Cards behind)
                            Rectangle {
                                visible: isStack && !expanded
                                width: parent.width - 24
                                height: headerCard.implicitHeight
                                anchors.horizontalCenter: parent.horizontalCenter
                                y: 8
                                color: Theme.alpha(Theme.colors.surface, Theme.blur.surfaceOpacity)
                                radius: Theme.geometry.radius
                                border.color: Theme.alpha(Theme.colors.surface, Theme.blur.surfaceOpacity)
                                border.width: 1
                            }

                            NotificationCard {
                                id: headerCard

                                width: parent.width
                                z: 1
                                notification: groupData.notifications[0].modelData
                                time: groupData.notifications[0].receivedAt
                                borderEnabled: false
                                padding: 0
                                showCloseButton: true
                                progress: 0
                                density: 1
                                onCloseClicked: {
                                    const notifs = groupData.notifications;
                                    if (!expanded && isStack) {
                                        for (let i = notifs.length - 1; i >= 0; i--) {
                                            if (notifs[i].modelData)
                                                notifs[i].modelData.dismiss();
                                        }
                                    } else {
                                        if (notifs[0].modelData)
                                            notifs[0].modelData.dismiss();
                                    }
                                }
                            }
                        }

                        // Expanded Notifications
                        Column {
                            width: parent.width
                            visible: expanded
                            spacing: Theme.geometry.spacing.small
                            opacity: expanded ? 1 : 0

                            Repeater {
                                model: isStack ? groupData.notifications.slice(1) : 0

                                delegate: NotificationCard {
                                    width: parent.width
                                    notification: modelData.modelData
                                    time: modelData.receivedAt
                                    borderEnabled: false
                                    padding: 0
                                    showCloseButton: true
                                    density: 1
                                    onCloseClicked: {
                                        if (modelData.modelData)
                                            modelData.modelData.dismiss();
                                    }
                                }
                            }

                            Item {
                                width: parent.width
                                height: 4
                            }

                            Behavior on opacity { BaseAnimation { speed: "normal" } }
                        }
                    }
                }
            }

        }

    }

}
