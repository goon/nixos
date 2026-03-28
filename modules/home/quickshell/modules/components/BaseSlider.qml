import qs
import ".."
import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    // Value properties
    property real value: 0
    property real from: 0
    property real to: 1
    property real stepSize: 0

    // Interaction
    property int orientation: Qt.Horizontal
    property bool interactive: true
    property alias pressed: mouseArea.pressed

    // Visual customization
    property color trackColor: Theme.colors.background
    property color fillColor: Theme.colors.primary
    property color handleColor: Theme.colors.text
    property color handleBorderColor: Theme.colors.text
    property int trackHeight: 12
    property int handleSize: 24
    property int handleWidth: 6

    // Content properties
    property string icon: ""
    property string suffix: ""
    property color iconColor: Theme.colors.muted
    property color suffixColor: Theme.colors.muted
    property int iconSize: Theme.dimensions.iconMedium
    property int fontSize: 11

    // Internal computed values
    readonly property real normalizedValue: (value - from) / (to - from)
    readonly property real fillSize: (orientation === Qt.Horizontal ? track.width : track.height) * normalizedValue

    // Signals
    signal moved()
    signal valueChangedByUser()
    signal iconClicked()

    implicitHeight: orientation === Qt.Horizontal ? Math.max(trackHeight, handleSize) : 100
    implicitWidth: orientation === Qt.Horizontal ? 100 : Math.max(trackHeight, handleSize)

    // Background track
    Rectangle {
        id: track

        anchors.centerIn: parent
        width: root.orientation === Qt.Horizontal ? parent.width : root.trackHeight
        height: root.orientation === Qt.Horizontal ? root.trackHeight : parent.height
        radius: Math.max(2, Theme.geometry.radius * 0.5)
        color: trackColor
        border.width: 0
        clip: true

        // Gradient fill
        Rectangle {
            id: fill

            width: root.orientation === Qt.Horizontal ? root.fillSize : parent.width
            height: root.orientation === Qt.Horizontal ? parent.height : root.fillSize
            radius: parent.radius
            anchors.bottom: root.orientation === Qt.Vertical ? parent.bottom : undefined
            anchors.left: root.orientation === Qt.Horizontal ? parent.left : undefined
            
            gradient: Gradient {
                orientation: root.orientation === Qt.Horizontal ? Gradient.Horizontal : Gradient.Vertical
                GradientStop { position: 0.0; color: Theme.colors.primary }
                GradientStop { position: 1.0; color: Theme.colors.secondary }
            }

            Behavior on width {
                enabled: root.orientation === Qt.Horizontal && !mouseArea.pressed
                BaseAnimation { duration: Theme.animations.fast }
            }

            Behavior on height {
                enabled: root.orientation === Qt.Vertical && !mouseArea.pressed
                BaseAnimation { duration: Theme.animations.fast }
            }
        }

        // Inside content (Icon and Suffix)
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.geometry.spacing.medium
            anchors.rightMargin: Theme.geometry.spacing.medium
            visible: root.orientation === Qt.Horizontal
            spacing: Theme.geometry.spacing.small

            Item {
                visible: root.icon !== ""
                Layout.preferredWidth: root.iconSize
                Layout.preferredHeight: root.iconSize
                Layout.alignment: Qt.AlignVCenter

                BaseIcon {
                    anchors.centerIn: parent
                    icon: root.icon
                    size: root.iconSize
                    color: root.iconColor
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.iconClicked()
                }
            }

            Item { Layout.fillWidth: true }

            BaseText {
                visible: root.suffix !== ""
                text: root.suffix
                color: root.suffixColor
                pixelSize: root.fontSize
                weight: Theme.typography.weights.medium
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }

    // Handle (only visible when interactive)
    Rectangle {
        id: handle

        visible: root.interactive && root.handleWidth > 0 && root.handleSize > 0 && root.trackHeight < 20
        width: root.orientation === Qt.Horizontal ? root.handleWidth : root.handleSize
        height: root.orientation === Qt.Horizontal ? root.handleSize : root.handleWidth
        radius: Math.max(2, Theme.geometry.radius * 0.5)
        x: root.orientation === Qt.Horizontal ? Math.max(0, Math.min(root.width - width, root.fillSize - width / 2)) : (root.width - width) / 2
        y: root.orientation === Qt.Vertical ? Math.max(0, Math.min(root.height - height, root.height - root.fillSize - height / 2)) : (root.height - height) / 2
        color: handleColor
        border.width: 0

        Behavior on x {
            enabled: root.orientation === Qt.Horizontal && !mouseArea.pressed
            BaseAnimation { duration: Theme.animations.fast }
        }

        Behavior on y {
            enabled: root.orientation === Qt.Vertical && !mouseArea.pressed
            BaseAnimation { duration: Theme.animations.fast }
        }

        // Tactile Shimmer Effect
        Rectangle {
            id: shimmer
            anchors.fill: parent
            radius: parent.radius
            color: Theme.colors.text
            opacity: 0
            clip: true

            gradient: Gradient {
                orientation: root.orientation === Qt.Horizontal ? Gradient.Vertical : Gradient.Horizontal
                GradientStop { position: 0.0; color: Theme.colors.transparent }
                GradientStop { position: 0.5; color: Theme.alpha(Theme.colors.text, 0.4) }
                GradientStop { position: 1.0; color: Theme.colors.transparent }
            }

            BaseAnimation {
                id: shimmerAnim
                target: shimmer; property: "opacity"
                from: 0; to: 0.8; duration: 200; easing.type: Easing.OutCubic
                onStopped: fadeOut.start()
            }
            BaseAnimation {
                id: fadeOut
                target: shimmer; property: "opacity"
                to: 0; duration: 400; easing.type: Easing.InCubic
            }

            // Trigger shimmer on interaction
            Connections {
                target: mouseArea
                function onPressed() { if (root.interactive) shimmerAnim.start(); }
            }
        }
    }

    // Mouse area for interaction
    MouseArea {
        id: mouseArea

        function updateValue(mousePos) {
            var newValue;
            if (root.orientation === Qt.Horizontal)
                newValue = root.from + (mousePos / width) * (root.to - root.from);
            else
                newValue = root.from + ((height - mousePos) / height) * (root.to - root.from);
            if (root.stepSize > 0)
                newValue = Math.round(newValue / root.stepSize) * root.stepSize;

            newValue = Math.max(root.from, Math.min(root.to, newValue));
            root.value = newValue;
            root.valueChangedByUser();
        }

        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        preventStealing: pressed
        cursorShape: Qt.PointingHandCursor
        onPressed: (mouse) => {
            mouse.accepted = true;
            updateValue(root.orientation === Qt.Horizontal ? mouse.x : mouse.y);
        }
        onPositionChanged: (mouse) => {
            if (pressed)
                updateValue(root.orientation === Qt.Horizontal ? mouse.x : mouse.y);
        }
        onReleased: root.moved()
    }
}
