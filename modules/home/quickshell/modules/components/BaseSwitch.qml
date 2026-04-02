import QtQuick
import QtQuick.Controls
import qs

Switch {
    id: control

    implicitWidth: 44
    implicitHeight: 24
    // Disable default background
    background: null
    
    // Customizable colors
    property color checkedColor: Theme.colors.primary
    property color uncheckedColor: Theme.colors.appBackground

    // Helper to ensure cursor changes
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.NoButton // Let clicks pass through to the Switch
    }

    indicator: Rectangle {
        implicitWidth: 44
        implicitHeight: 24
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: Math.max(2, Theme.geometry.radius * 0.5)
        // Track Color
        color: {
            if (!control.enabled) return control.uncheckedColor;
            return control.checked ? control.checkedColor : control.uncheckedColor;
        }
        // Track Border
        border.width: 0

        // Thumb
        Rectangle {
            id: thumb

            property real targetX: control.checked ? parent.width - 16 - 4 : 4
            x: targetX
            y: 4
            
            property real stretch: {
                var maxTravel = parent.width - 24
                if (maxTravel <= 0) return 0
                // Normalize the distance from target and apply a sine wave to bulge in the middle
                var norm = Math.abs(x - targetX) / maxTravel
                return Math.max(0, Math.sin(norm * Math.PI) * 12)
            }
            
            width: 16 + stretch
            height: 16
            radius: Math.max(0, Math.max(2, Theme.geometry.radius * 0.5) - 2)
            // Thumb Color
            color: control.checked ? Theme.colors.base : Theme.colors.text

            Behavior on x {
                BaseAnimation { speed: "fast"; easing.type: Easing.OutBack }
            }
        }

        Behavior on color {
            BaseAnimation {
                speed: "fast"
            }
        }

        Behavior on border.color {
            BaseAnimation {
                speed: "fast"
            }
        }

    }

}
