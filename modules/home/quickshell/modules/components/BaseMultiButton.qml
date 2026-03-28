import QtQuick
import QtQuick.Layouts
import qs

Item {
    id: root

    property var model: []
    property int selectedIndex: -1
    property int orientation: Qt.Horizontal
    property bool showHighlight: true
    property Gradient highlightGradient: Gradient {
        orientation: root.orientation === Qt.Horizontal ? Gradient.Horizontal : Gradient.Vertical
        GradientStop { position: 0.0; color: Theme.colors.primary }
        GradientStop { position: 1.0; color: Theme.colors.secondary }
    }
    property bool gradient: true
    property bool buttonHoverEnabled: false
    property int buttonCustomRadius: -1
    property int spacing: 4
    property int buttonHeight: 42
    property int padding: 4

    signal buttonClicked(int index)

    Layout.fillWidth: true
    implicitHeight: buttonHeight + (padding * 2)

    Rectangle {
        id: highlight
        visible: root.showHighlight && root.selectedIndex >= 0
        x: root.orientation === Qt.Horizontal ? root.padding + (root.selectedIndex * (width + root.spacing)) : root.padding
        y: root.orientation === Qt.Vertical ? root.padding + (root.selectedIndex * (height + root.spacing)) : root.padding
        width: root.orientation === Qt.Horizontal ? (parent.width - (root.padding * 2) - (root.spacing * (root.model.length - 1))) / root.model.length : parent.width - (root.padding * 2)
        height: root.orientation === Qt.Horizontal ? parent.height - (root.padding * 2) : (parent.height - (root.padding * 2) - (root.spacing * (root.model.length - 1))) / root.model.length
        radius: root.buttonCustomRadius >= 0 ? root.buttonCustomRadius : Theme.geometry.radius
        color: Theme.colors.transparent

        // Premium Border Gradient
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: root.highlightGradient
            visible: root.gradient
        }

        // Inner Cutout for Premium Style
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1.5
            radius: parent.radius - 1.5
            color: Theme.colors.surface
            visible: root.gradient

            // Selection tint overlay
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: Qt.alpha(Theme.colors.primary, 0.08)
            }
        }

        // Legacy Solid Gradient
        gradient: !root.gradient ? root.highlightGradient : null

        Behavior on x {
            BaseAnimation {
                duration: Theme.animations.normal
                easing.type: Easing.OutQuint
            }
        }

        Behavior on y {
            BaseAnimation {
                duration: Theme.animations.normal
                easing.type: Easing.OutQuint
            }
        }
    }

    Loader {
        anchors.fill: parent
        sourceComponent: root.orientation === Qt.Horizontal ? horizontalLayoutComponent : verticalLayoutComponent
    }

    Component {
        id: horizontalLayoutComponent

        RowLayout {
            anchors.fill: parent
            anchors.margins: root.padding
            spacing: root.spacing

            Repeater {
                model: root.model

                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    enabled: modelData.enabled !== false
                    radius: root.buttonCustomRadius >= 0 ? root.buttonCustomRadius : Theme.geometry.radius
                    color: mouseArea.containsMouse && (root.buttonHoverEnabled || root.gradient) ? Theme.alpha(Theme.colors.text, 0.05) : Theme.colors.transparent

                    property bool isSelected: index === root.selectedIndex

                    Behavior on color {
                        BaseAnimation { duration: Theme.animations.fast }
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: !!modelData.icon ? Theme.geometry.spacing.medium : 0

                        BaseIcon {
                            visible: !!modelData.icon
                            icon: modelData.icon ?? ""
                            size: Theme.typography.size.large
                            color: {
                                if (!parent.parent.isSelected) return Theme.colors.text;
                                return root.gradient ? Theme.colors.primary : Theme.colors.base;
                            }
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        BaseText {
                            text: modelData.text ?? ""
                            color: {
                                if (!parent.parent.isSelected) return Theme.colors.text;
                                return root.gradient ? Theme.colors.text : Theme.colors.base;
                            }
                            pixelSize: Theme.typography.size.medium
                            weight: parent.parent.isSelected && root.gradient ? Theme.typography.weights.bold : Theme.typography.weights.normal
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        enabled: parent.enabled
                        hoverEnabled: true
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            root.selectedIndex = index
                            root.buttonClicked(index)
                        }
                    }
                }
            }
        }
    }

    Component {
        id: verticalLayoutComponent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: root.padding
            spacing: root.spacing

            Repeater {
                model: root.model

                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    enabled: modelData.enabled !== false
                    radius: root.buttonCustomRadius >= 0 ? root.buttonCustomRadius : Theme.geometry.radius
                    color: mouseArea.containsMouse && (root.buttonHoverEnabled || root.gradient) ? Theme.alpha(Theme.colors.text, 0.05) : Theme.colors.transparent

                    property bool isSelected: index === root.selectedIndex

                    Behavior on color {
                        BaseAnimation { duration: Theme.animations.fast }
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: !!modelData.icon ? Theme.geometry.spacing.medium : 0

                        BaseIcon {
                            visible: !!modelData.icon
                            icon: modelData.icon ?? ""
                            size: Theme.typography.size.large
                            color: {
                                if (!parent.parent.isSelected) return Theme.colors.text;
                                return root.gradient ? Theme.colors.primary : Theme.colors.base;
                            }
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        BaseText {
                            text: modelData.text ?? ""
                            color: {
                                if (!parent.parent.isSelected) return Theme.colors.text;
                                return root.gradient ? Theme.colors.text : Theme.colors.base;
                            }
                            pixelSize: Theme.typography.size.medium
                            weight: parent.parent.isSelected && root.gradient ? Theme.typography.weights.bold : Theme.typography.weights.normal
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        enabled: parent.enabled
                        hoverEnabled: true
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            root.selectedIndex = index
                            root.buttonClicked(index)
                        }
                    }
                }
            }
        }
    }
}
