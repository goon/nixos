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
    readonly property bool hovered: mouseArea.containsMouse

    // Visual customization

    property color trackColor: Theme.colors.background
    property color fillColor: Theme.colors.primary
    property color handleColor: bigMode ? Theme.colors.surface : Theme.colors.text
    property color handleBorderColor: bigMode ? Theme.colors.border : Theme.colors.text
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
    readonly property real fillSize: root.orientation === Qt.Horizontal ? root.width * root.normalizedValue : root.height * root.normalizedValue
    readonly property bool bigMode: trackHeight >= 20

    // Coolness Controls
    property real interactionScale: (root.hovered || root.pressed) ? 1.05 : 1.0
    property real breathOpacity: 1.0
    property bool isActive: root.hovered || root.pressed

    SequentialAnimation on breathOpacity {
        id: breathAnim
        running: root.pressed && root.bigMode
        loops: Animation.Infinite
        NumberAnimation { from: 1.0; to: 0.75; duration: 800; easing.type: Easing.InOutQuad }
        NumberAnimation { from: 0.75; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
        onStopped: root.breathOpacity = 1.0
    }

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
        radius: root.bigMode ? Theme.geometry.radius : Math.max(2, Theme.geometry.radius * 0.5)
        color: trackColor
        border.width: 0
        clip: true

        // Gradient fill
        Rectangle {
            id: fill

            width: root.bigMode ? (root.value > root.from ? (handle.x + handle.width + 4) : 0) : root.fillSize
            height: root.orientation === Qt.Horizontal ? parent.height : root.fillSize
            radius: parent.radius
            anchors.bottom: root.orientation === Qt.Vertical ? parent.bottom : undefined
            anchors.top: root.orientation === Qt.Vertical ? (root.bigMode ? (handle.y - 4) : undefined) : undefined
            anchors.left: root.orientation === Qt.Horizontal ? parent.left : undefined
            
            opacity: root.pressed && root.bigMode ? root.breathOpacity : 1.0
            
            gradient: Gradient {
                orientation: root.orientation === Qt.Horizontal ? Gradient.Horizontal : Gradient.Vertical
                GradientStop { position: 0.0; color: Theme.colors.primary }
                GradientStop { position: 1.0; color: Theme.colors.secondary }
            }

            Behavior on width {
                enabled: !root.bigMode && root.orientation === Qt.Horizontal && !mouseArea.pressed
                BaseAnimation { duration: Theme.animations.fast }
            }

            Behavior on height {
                enabled: !root.bigMode && root.orientation === Qt.Vertical && !mouseArea.pressed
                BaseAnimation { duration: Theme.animations.fast }
            }
        }

        // Inside content (Icon and Suffix)
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.geometry.spacing.medium
            anchors.rightMargin: Theme.geometry.spacing.medium
            visible: root.orientation === Qt.Horizontal && !root.bigMode
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

        visible: root.interactive && root.handleWidth > 0 && root.handleSize > 0
        width: root.bigMode ? (root.trackHeight - 8) : (root.orientation === Qt.Horizontal ? root.handleWidth : root.handleSize)
        height: root.bigMode ? (root.trackHeight - 8) : (root.orientation === Qt.Horizontal ? root.handleSize : root.handleWidth)
        radius: root.bigMode ? Theme.geometry.radius : Math.max(2, Theme.geometry.radius * 0.5)
        
        // Synchronize movement: knob and fill edge move together for big sliders, center for normal ones
        x: root.bigMode ? (root.orientation === Qt.Horizontal ? (4 + (root.width - width - 8) * root.normalizedValue) : (root.width - width) / 2)
                        : (root.orientation === Qt.Horizontal ? Math.max(0, Math.min(root.width - width, root.fillSize - width / 2)) : (root.width - width) / 2)
        y: root.bigMode ? (root.orientation === Qt.Vertical ? (4 + (root.height - height - 8) * (1.0 - root.normalizedValue)) : (root.height - height) / 2)
                        : (root.orientation === Qt.Vertical ? Math.max(0, Math.min(root.height - height, root.fillSize - height / 2)) : (root.height - height) / 2)
        
        color: root.bigMode ? Theme.alpha(handleColor, 0.95) : handleColor
        border.color: Theme.alpha(handleBorderColor, (root.isActive && root.bigMode ? 0.3 : 0.15))
        border.width: root.bigMode ? 1 : 0
        z: 10

        scale: root.bigMode ? root.interactionScale : 1.0
        Behavior on scale { BaseAnimation { duration: 250; easing.type: Easing.OutBack } }

        // Subtle glow effect when active
        Rectangle {
            anchors.fill: parent
            anchors.margins: -4
            radius: parent.radius + 4
            color: "transparent"
            border.width: 2
            border.color: Theme.alpha(root.fillColor, 0.3)
            visible: root.bigMode && root.isActive
            opacity: root.pressed ? 1.0 : 0.5
            z: -2
            
            SequentialAnimation on opacity {
                running: root.isActive && root.bigMode
                loops: Animation.Infinite
                NumberAnimation { from: 0.2; to: 0.6; duration: 1000; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 0.6; to: 0.2; duration: 1000; easing.type: Easing.InOutQuad }
            }
        }

        // Sublte depth effect for big sliders
        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: parent.radius
            color: "transparent"
            border.width: 1
            border.color: Theme.alpha(Theme.colors.background, 0.2)
            visible: root.bigMode
            z: -1
        }

        // Handle Content (Icon/Suffix Switch with Fading)
        Item {
            anchors.fill: parent
            anchors.margins: 4
            visible: root.bigMode && root.orientation === Qt.Horizontal

            BaseIcon {
                anchors.centerIn: parent
                icon: root.icon
                size: Math.min(parent.width, root.iconSize)
                color: root.iconColor
                opacity: (!root.hovered && !root.pressed) ? 1 : 0
                Behavior on opacity { BaseAnimation { duration: 400; easing.type: Easing.InOutQuad } }
            }

            BaseText {
                anchors.fill: parent
                text: root.suffix
                color: root.suffixColor
                pixelSize: Math.min(parent.height - 4, root.fontSize + 1)
                fontSizeMode: Text.Fit
                minimumPixelSize: 8
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.NoWrap
                font.weight: Theme.typography.weights.bold
                opacity: (root.hovered || root.pressed) ? 1 : 0
                Behavior on opacity { BaseAnimation { duration: 400; easing.type: Easing.InOutQuad } }
            }
        }

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
