import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.services
import qs

BasePopoutWindow {
    id: root
    
    panelNamespace: "quickshell:settings"
    fixedWidth: 800


    body: Item {
        id: mainContainer
        implicitWidth: root.fixedWidth
        
        readonly property real maxHeight: (root.popupWindow && root.popupWindow.screen) 
            ? Math.min(900, root.popupWindow.screen.height * 0.9)
            : 800

        implicitHeight: Math.min(maxHeight, mainLayout.implicitHeight)

        property alias pageStack: pageStack

        Connections {
            target: root
            function onClosed() {
                pageStack.replace("pages/About.qml");
                navButton.selectedIndex = 0; // About is now the 1st item
            }
        }


        // MAIN LAYOUT
        ColumnLayout {
            id: mainLayout
            width: parent.width
            height: parent.height
            spacing: Theme.geometry.spacing.large

            // 1. TOP NAVIGATION
            BaseBlock {
                id: navBlock
                Layout.fillWidth: true
                padding: 4
                blockRadius: Theme.geometry.radius

                BaseMultiButton {
                    id: navButton
                    model: [
                        { text: "About", icon: "info", page: "About" },
                        { text: "Appearance", icon: "palette", page: "Appearance" },
                        { text: "Wallpaper", icon: "image", page: "Wallpaper" },
                        { text: "System", icon: "settings", page: "System" },
                        { text: "General", icon: "tune", page: "General" }
                    ]
                    selectedIndex: 0 // Initial page: About
                    buttonCustomRadius: navBlock.blockRadius - navBlock.padding
                    
                    onButtonClicked: (index) => {
                        var page = model[index].page;
                        pageStack.replace("pages/" + page + ".qml");
                    }
                }
            }

            // 2. CONTENT AREA
            Item {
                Layout.fillWidth: true
                implicitHeight: centeredContainer.implicitHeight
                Layout.fillHeight: true

                // Mask for rounded clipping
                Rectangle {
                    id: contentMask
                    anchors.fill: parent
                    radius: Theme.geometry.radius
                    color: "white"
                    visible: false
                    layer.enabled: true
                }

                // Clipped container
                Item {
                    anchors.fill: parent
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        maskEnabled: true
                        maskSource: contentMask
                    }

                    BaseScroller {
                        id: contentScroller
                        anchors.fill: parent
                        clip: false

                        ColumnLayout {
                            id: centeredContainer
                            width: parent.width
                            spacing: 0

                            StackView {
                                id: pageStack
                                Layout.fillWidth: true
                                implicitHeight: currentItem ? currentItem.implicitHeight : 0
                                initialItem: "pages/About.qml"

                                replaceEnter: Transition {
                                    ParallelAnimation {
                                        BaseAnimation { property: "opacity"; from: 0; to: 1; speed: "normal"; easing.type: Easing.OutQuad }
                                        BaseAnimation { property: "scale"; from: 0.98; to: 1; speed: "normal"; easing.type: Easing.OutQuad }
                                    }
                                }

                                replaceExit: Transition {
                                    BaseAnimation { property: "opacity"; from: 1; to: 0; speed: "normal"; easing.type: Easing.OutQuad }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
