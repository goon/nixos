import QtQuick
import QtQuick.Controls
import qs
import "."

SpinBox {
    id: root

    property int radius: Theme.geometry.radius
    property color backgroundColor: Theme.colors.background
    property color textColor: Theme.colors.text
    property color borderColor: Theme.colors.border
    property color activeBorderColor: Theme.colors.primary

    from: 0
    to: 100
    stepSize: 1
    editable: true

    background: Rectangle {
        implicitWidth: 100
        implicitHeight: 36
        color: root.backgroundColor
        border.width: 1
        border.color: root.activeFocus ? root.activeBorderColor : root.borderColor
        radius: root.radius
    }

    contentItem: TextInput {
        text: root.textFromValue(root.value, root.locale)
        color: root.textColor
        font.pixelSize: Theme.typography.size.medium
        font.family: Theme.typography.family
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        readOnly: !root.editable
        validator: root.validator
        inputMethodHints: Qt.ImhDigitsOnly
    }

    up.indicator: BaseIcon {
        x: root.width - width - 4
        y: 4
        size: Theme.dimensions.iconBase
        icon: "expand_less"
        color: root.textColor
        opacity: 1
    }

    down.indicator: BaseIcon {
        x: root.width - width - 4
        y: root.height - height - 4
        size: Theme.dimensions.iconBase
        icon: "expand_more"
        color: root.textColor
        opacity: 1
    }
}
