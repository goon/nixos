import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs

PanelWindow {
    id: bar

    property var leftComponents: Preferences.barLeftComponents
    readonly property var centerComponents: Preferences.barCenterComponents
    readonly property var rightComponents: Preferences.barRightComponents
    readonly property real sideMargin: Math.max(0, (bar.implicitHeight - (Theme.dimensions.barItemHeight * Theme.barScale)) / 2)

    function resolveComponentSource(name) {
        const map = {
            "workspaces": "components/Workspaces.qml",
            "tray": "components/Tray.qml",
            "volume": "components/Volume.qml",
            "clock": "components/Clock.qml",
            "nowPlaying": "components/NowPlaying.qml",
            "notifications": "components/Notifications.qml",
            "dock": "components/Dock.qml",
            "stats": "components/SystemResources.qml",
            "systemControl": "components/SystemControl.qml"
        };
        return map[name] || "";
    }

    objectName: "bar"
    color: Theme.colors.transparent
    focusable: false
    WlrLayershell.namespace: "quickshell:bar"
    WlrLayershell.layer: WlrLayer.Top
    implicitHeight: Preferences.barHeight
    implicitWidth: {
        if (Preferences.barFitToContent) {
            return (centerSection.implicitWidth * Theme.barScale) + (bar.sideMargin * 2);
        } else {
            return 0;
        }
    }

    anchors {
        top: Preferences.barPosition === "top"
        bottom: Preferences.barPosition === "bottom"
        left: !Preferences.barFitToContent
        right: !Preferences.barFitToContent
    }

    margins {
        top: Preferences.barPosition === "top" ? Preferences.barMarginTop : 0
        bottom: Preferences.barPosition === "bottom" ? Preferences.barMarginTop : 0
        left: Preferences.barMarginSide
        right: Preferences.barMarginSide
    }

    Item {
        id: emptyBlurArea
        width: 1; height: 1
        opacity: 0
    }

    BackgroundEffect.blurRegion: blurRegionItem

    Region {
        id: blurRegionItem
        item: Preferences.blurEnabled ? barBackground : emptyBlurArea
        radius: Theme.geometry.radius
    }

    BaseBackground {
        id: barBackground

        readonly property real maxSideWidth: Math.max(leftContent.implicitWidth, rightContent.implicitWidth)

        RowLayout {
            id: contentLayout

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            width: (Preferences.barFitToContent ? implicitWidth : (parent.width - (bar.sideMargin * 2)) / Theme.barScale)
            spacing: bar.sideMargin / Theme.barScale
            
            transform: Scale {
                origin.x: contentLayout.width / 2
                origin.y: contentLayout.height / 2
                xScale: Theme.barScale
                yScale: Theme.barScale
            }

            // 1. Left Section
            RowLayout {
                id: leftSection

                // Visible if NOT Fit to Content AND EITHER side has components
                visible: !Preferences.barFitToContent && (bar.leftComponents.length > 0 || bar.rightComponents.length > 0)
                Layout.preferredWidth: barBackground.maxSideWidth
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                spacing: 0

                // Content Wrapper
                RowLayout {
                    id: leftContent

                    spacing: bar.sideMargin / Theme.barScale

                    Repeater {
                        model: bar.leftComponents

                        Loader {
                            Layout.alignment: Qt.AlignVCenter
                            source: bar.resolveComponentSource(modelData)
                            
                            visible: {
                                switch(modelData) {
                                    case "dock": return Compositor.windows.length > 0;
                                    case "nowPlaying": return Media.activePlayer !== null;
                                    case "tray": return TrayService.itemCount > 0;
                                    default: return true;
                                }
                            }

                            Binding {
                                target: item
                                property: "barWindow"
                                value: bar
                                when: item !== null && modelData === "tray"
                            }

                        }

                    }

                }

                // Trailing spacer
                Item {
                    Layout.fillWidth: true
                }

            }

            Item {
                Layout.fillWidth: true
                visible: !Preferences.barFitToContent
            }

            RowLayout {
                id: centerSection

                visible: bar.centerComponents.length > 0
                Layout.alignment: Qt.AlignCenter | Qt.AlignVCenter
                spacing: bar.sideMargin / Theme.barScale

                Repeater {
                    model: bar.centerComponents

                    Loader {
                        Layout.alignment: Qt.AlignVCenter
                        source: bar.resolveComponentSource(modelData)
                        
                        visible: {
                            switch(modelData) {
                                case "dock": return Compositor.windows.length > 0;
                                case "nowPlaying": return Media.activePlayer !== null;
                                case "tray": return TrayService.itemCount > 0;
                                default: return true;
                            }
                        }

                        Binding {
                            target: item
                            property: "barWindow"
                            value: bar
                            when: item !== null && modelData === "tray"
                        }

                    }

                }

            }

            Item {
                Layout.fillWidth: true
                visible: !Preferences.barFitToContent
            }

            RowLayout {
                id: rightSection

                visible: !Preferences.barFitToContent && (bar.leftComponents.length > 0 || bar.rightComponents.length > 0)
                Layout.preferredWidth: barBackground.maxSideWidth
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                spacing: 0

                // Leading spacer
                Item {
                    Layout.fillWidth: true
                }

                // Content Wrapper
                RowLayout {
                    id: rightContent

                    spacing: bar.sideMargin / Theme.barScale

                    Repeater {
                        model: bar.rightComponents

                        Loader {
                            Layout.alignment: Qt.AlignVCenter
                            source: bar.resolveComponentSource(modelData)
                            
                            visible: {
                                switch(modelData) {
                                    case "dock": return Compositor.windows.length > 0;
                                    case "nowPlaying": return Media.activePlayer !== null;
                                    case "tray": return TrayService.itemCount > 0;
                                    default: return true;
                                }
                            }

                            Binding {
                                target: item
                                property: "barWindow"
                                value: bar
                                when: item !== null && modelData === "tray"
                            }

                        }

                    }

                }

            }

        }

    }

    Behavior on implicitHeight {
        BaseAnimation {
            duration: Theme.animations.fast
        }

    }

    onWidthChanged: PopoutService.barWidth = width

}
