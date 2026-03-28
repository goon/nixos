import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs

BaseBlock {
    id: root

    property Component trayMenuComponent: internalTrayMenuComponent
    property var barWindow: null

    visible: TrayService.itemCount > 0
    implicitWidth: layout.implicitWidth + (paddingHorizontal * 2)
    implicitHeight: Theme.dimensions.barItemHeight
    paddingHorizontal: Theme.geometry.spacing.dynamicPadding
    paddingVertical: 0
    blockRadius: Theme.geometry.radius
    clickable: false // Tray background isn't clickable, only items are
    hoverEnabled: false

    Component {
        id: internalTrayMenuComponent

        TrayPopout {
        }

    }

    // Delegate for the tray items
    Component {
        id: trayItemDelegate

        Item {
            id: delegateRoot

            // Alias modelData for easier access and safety
            readonly property var trayData: modelData

            implicitWidth: Theme.dimensions.iconBase
            implicitHeight: Theme.dimensions.iconBase

            Image {
                id: trayIcon

                anchors.fill: parent
                // SystemTray items provide image:// URLs or icon names
                // StatusNotifierItem icon property is usually the correct source
                source: {
                    if (!trayData)
                        return "";

                    // Try to resolve by ID first (similar to how Dock uses appId)
                    // This helps match the theme's brand icons over app-provided symbolic ones.
                    var resolved = LauncherService.resolveIcon(trayData.id);
                    if (resolved)
                        return resolved;

                    // Fallback to the icon name/path provided by the application
                    return LauncherService.resolveIcon(trayData.icon) || "";
                }
                sourceSize: Qt.size(48, 48) // High res for smooth scaling
                fillMode: Image.PreserveAspectFit
                smooth: true
                asynchronous: true
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                hoverEnabled: true
                onClicked: (mouse) => {
                    // Formal parameter to avoid deprecation warning
                    if (!trayData)
                        return ;

                    if (mouse.button === Qt.LeftButton) {
                        trayData.activate();
                    } else if (mouse.button === Qt.RightButton) {
                        if (trayData.menu) {
                            TrayService.closeCurrentMenu();
                            PopoutService.closeAll();
                            if (trayMenuComponent.status === Component.Ready) {
                                var iconGlobalPos = trayIcon.mapToItem(null, 0, 0);
                                // Calculate bar bounds for clamping (screen-space)
                                var barWidth = root.barWindow ? root.barWindow.width : 0;
                                var screen = Quickshell.screens[0];
                                var barScreenX = 0;
                                if (root.barWindow) {
                                    if (Preferences.barFitToContent)
                                        barScreenX = (screen.width - barWidth) / 2;
                                    else
                                        barScreenX = Preferences.barMarginSide;
                                }
                                var menu = trayMenuComponent.createObject(root, {
                                    "trayItem": trayData,
                                    "anchorX": barScreenX + iconGlobalPos.x + (trayIcon.width / 2),
                                    "anchorMinX": barScreenX,
                                    "anchorMaxX": barScreenX + barWidth
                                });
                                if (menu) {
                                    menu.open();
                                    // BaseFloating handles its own windowing, so we just track it.
                                    TrayService.openMenu(menu, trayData, Qt.point(iconGlobalPos.x, iconGlobalPos.y));
                                }
                            }
                        }
                    } else if (mouse.button === Qt.MiddleButton) {
                        trayData.secondaryActivate();
                    }
                }
            }

        }

    }

    // Wrap content to avoid ColumnLayout vs Anchors conflict in BaseBlock
    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        implicitWidth: layout.implicitWidth
        implicitHeight: layout.implicitHeight

        RowLayout {
            id: layout

            anchors.centerIn: parent
            spacing: Theme.geometry.spacing.small

            Repeater {
                model: SystemTray.items.values
                delegate: trayItemDelegate
            }

        }

    }

}
