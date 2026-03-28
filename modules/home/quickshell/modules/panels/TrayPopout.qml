import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import qs

BasePopoutWindow {
    id: root

    property var trayItem: null
    property var menu: (trayItem && trayItem.menu ? trayItem.menu : null)
    
    // Submenu support
    property bool isSubMenu: false
    property var parentPopout: null

    panelNamespace: isSubMenu ? "quickshell:tray-submenu" : "quickshell:tray-popout"

    onClosed: Qt.callLater(() => root.destroy())

    // Logic to calculate submenu position
    function showSubMenu(item, menuData) {
        var component = Qt.createComponent("TrayPopout.qml");
        var globalPos = item.mapToItem(null, 0, 0);
        
        var sub = component.createObject(root.parent, {
            "trayItem": root.trayItem,
            "menu": menuData,
            "isSubMenu": true,
            "parentPopout": root,
            "manualX": globalPos.x + item.width - 20, // Slight overlap
            "manualY": globalPos.y - Theme.geometry.spacing.medium // Align with item
        });
        
        if (sub) {
            sub.open();
        }
    }

    body: Flickable {
        id: flickable
        
        QsMenuOpener {
            id: opener
            menu: root.menu
        }

        implicitWidth: Theme.dimensions.trayMenuWidth
        implicitHeight: trayBlock.implicitHeight
        contentHeight: trayBlock.implicitHeight
        clip: true
        interactive: contentHeight > height

        BaseBlock {
            id: trayBlock
            width: parent.width
            padding: Theme.geometry.spacing.dynamicPadding
            blockRadius: Theme.geometry.radius

            ColumnLayout {
                id: menuColumn
                width: parent.width
                spacing: 6

                Repeater {
                    model: opener.children

                    delegate: Rectangle {
                        id: itemRoot
                        Layout.fillWidth: true
                        Layout.preferredHeight: itemContent.implicitHeight + 8
                        color: Theme.colors.transparent
                        radius: Theme.geometry.radius
                        visible: !isSeparator

                        readonly property bool isSeparator: modelData.isSeparator
                        readonly property bool hasSubMenu: modelData.hasChildren

                        BaseButton {
                            id: itemButton
                            anchors.fill: parent
                            visible: !isSeparator
                            gradient: true
                            selected: containsMouse
                            normalColor: Theme.colors.transparent
                            hoverColor: Theme.colors.transparent
                            
                            onClicked: {
                                if (!modelData) return;
                                if (hasSubMenu) {
                                    root.showSubMenu(itemRoot, modelData);
                                } else {
                                    modelData.triggered();
                                    // Close the whole chain
                                    var p = root;
                                    while (p) {
                                        p.close();
                                        p = p.parentPopout;
                                    }
                                }
                            }

                            RowLayout {
                                id: itemContent
                                anchors.fill: parent
                                anchors.leftMargin: Theme.geometry.spacing.dynamicPadding
                                anchors.rightMargin: Theme.geometry.spacing.dynamicPadding
                                spacing: Theme.geometry.spacing.small

                                BaseIcon {
                                    icon: (modelData && modelData.iconName) ? modelData.iconName : ""
                                    size: Theme.dimensions.iconBase
                                    visible: icon !== ""
                                    color: (modelData && modelData.enabled) ? itemButton.iconColor : Theme.colors.muted
                                }

                                 BaseText {
                                    Layout.fillWidth: true
                                    text: (modelData && modelData.text) ? modelData.text.replace(/&/g, "") : ""
                                    color: (modelData && modelData.enabled) ? itemButton.textColor : Theme.colors.muted
                                    elide: Text.ElideRight
                                }

                                BaseIcon {
                                    icon: "chevron_right"
                                    size: Theme.dimensions.iconSmall
                                    visible: hasSubMenu
                                    color: (modelData && modelData.enabled) ? itemButton.iconColor : Theme.colors.muted
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
