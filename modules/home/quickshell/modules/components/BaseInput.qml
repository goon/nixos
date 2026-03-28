import QtQuick
import QtQuick.Controls
import qs

TextField {
    id: root

    // Customizable properties
    property color backgroundColor: Theme.colors.background
    property color borderColor: root.activeFocus ? Theme.colors.primary : Theme.colors.border
    property int borderWidth: 1
    property int borderRadius: Theme.geometry.radius
    property int inputPadding: Theme.geometry.spacing.dynamicPadding

    // Styling
    color: Theme.colors.text
    font.family: Theme.typography.family
    font.pixelSize: Theme.typography.size.base
    placeholderTextColor: Theme.colors.muted
    leftPadding: inputPadding
    rightPadding: inputPadding
    topPadding: 0
    bottomPadding: 0
    verticalAlignment: Text.AlignVCenter

    background: Rectangle {
        color: root.backgroundColor
        radius: root.borderRadius
        border.color: root.borderColor
        border.width: root.borderWidth

        Behavior on border.color {
            BaseAnimation {
                duration: Theme.animations.fast
            }

        }

    }

}
