import ".."
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import qs

Rectangle {
    id: root

    property string text: ""
    property string icon: ""
    property color iconColor: {
        if ((root.gradient && root.selected) || (root.hoverGradient && mouseArea.containsMouse)) return Theme.colors.primary;
        return (mouseArea.pressed || mouseArea.containsMouse) ? Theme.colors.primary : Theme.colors.text;
    }
    property color textColor: {
        if ((root.gradient && root.selected) || (root.hoverGradient && mouseArea.containsMouse)) return Theme.colors.text;
        return (mouseArea.pressed || mouseArea.containsMouse) ? Theme.colors.primary : Theme.colors.text;
    }
    property int size: Theme.dimensions.iconBase
    property alias iconSize: root.size
    property real rotation: 0
    property alias iconRotation: root.rotation
    property int textSize: Theme.typography.size.base
    property alias textWeight: root.weight
    property int weight: (root.gradient && root.selected) || (root.hoverGradient && mouseArea.containsMouse) ? Theme.typography.weights.bold : Theme.typography.weights.normal
    property color normalColor: Theme.colors.surface
    property color hoverColor: Theme.colors.transparent
    property color activeColor: Theme.colors.transparent
    property color borderColor: Theme.colors.transparent
    property int borderWidth: 0
    property real customRadius: -1
    property bool circular: false
    property bool gradient: false
    property bool selected: false
    property bool hoverGradient: false
    property bool hoverEnabled: true
    property bool hoverRotate: false
    property int paddingHorizontal: text !== "" ? Theme.geometry.spacing.dynamicPadding : Theme.geometry.spacing.medium
    property int paddingVertical: Theme.geometry.spacing.medium
    property int contentAlignment: Qt.AlignCenter
    property bool allowFallback: false
    readonly property alias containsMouse: mouseArea.containsMouse
    readonly property alias pressed: mouseArea.pressed

    signal clicked()
    signal rightClicked()
    signal pressedSignal()
    signal releasedSignal()
    signal entered()
    signal exited()

    radius: {
        if (customRadius >= 0)
            return customRadius;

        return circular ? height / 2 : Theme.geometry.radius;
    }
    color: normalColor
    border.color: borderColor
    border.width: borderWidth
    implicitWidth: childrenLayout.implicitWidth + (paddingHorizontal * 2)
    implicitHeight: childrenLayout.implicitHeight + (paddingVertical * 2)
    scale: pressed ? 0.98 : 1.0

    Behavior on scale {
        BaseAnimation {
            duration: Theme.animations.fast
        }
    }
    Layout.preferredWidth: (text === "" && icon !== "") ? implicitHeight : -1

    Rectangle {
        id: stateLayer

        anchors.fill: parent
        radius: parent.radius
        color: Theme.colors.transparent

        // Premium Border Gradient
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Theme.colors.primary }
                GradientStop { position: 1.0; color: Theme.colors.secondary }
            }
            visible: (root.gradient && root.selected) || (root.hoverGradient && mouseArea.containsMouse)
        }

        // Inner Cutout for Premium Style
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1.5
            radius: parent.radius - 1.5
            color: Theme.colors.surface
            visible: (root.gradient && root.selected) || (root.hoverGradient && mouseArea.containsMouse)

            // Selection tint overlay
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: Qt.alpha(Theme.colors.primary, 0.08)
            }
        }

        // Inner highlight for "glass" look
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.alpha(Theme.colors.text, 0.05) }
                GradientStop { position: 1.0; color: Theme.colors.transparent }
            }
            visible: (root.gradient && root.selected) || (root.hoverGradient && mouseArea.containsMouse)
        }

        // Standard Hover Layer
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: {
                if (!root.hoverEnabled)
                    return Theme.colors.transparent;

                if (mouseArea.containsMouse && root.hoverColor !== Theme.colors.transparent)
                    return root.hoverColor;

                if (mouseArea.containsMouse)
                    return Theme.colors.background;

                return Theme.colors.transparent;
            }
            visible: !root.selected && !root.gradient && !root.hoverGradient
        }

    }

    BaseIcon {
        id: childrenLayout

        anchors.centerIn: contentAlignment === Qt.AlignCenter ? parent : undefined
        anchors.left: contentAlignment === Qt.AlignLeft ? parent.left : undefined
        anchors.right: contentAlignment === Qt.AlignRight ? parent.right : undefined
        anchors.leftMargin: contentAlignment === Qt.AlignLeft ? paddingHorizontal : 0
        anchors.rightMargin: contentAlignment === Qt.AlignRight ? paddingHorizontal : 0
        anchors.verticalCenter: parent.verticalCenter
        icon: root.icon
        text: root.text
        color: root.iconColor
        textColor: root.textColor
        size: root.size
        textSize: root.textSize
        textWeight: root.weight
        rotation: root.rotation
        allowFallback: root.allowFallback
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton)
                root.rightClicked();
            else
                root.clicked();
        }
        onPressed: root.pressedSignal()
        onReleased: root.releasedSignal()
        onEntered: root.entered()
        onExited: root.exited()
    }

    SequentialAnimation {
        id: hoverRotateAnim
        NumberAnimation {
            target: root
            property: "rotation"
            from: 0
            to: 360
            duration: Theme.animations.normal
            easing.type: Easing.OutBack
        }
        PropertyAction { target: root; property: "rotation"; value: 0 }
    }

    onContainsMouseChanged: {
        if (containsMouse && hoverRotate) {
            hoverRotateAnim.restart();
        }
    }
}
