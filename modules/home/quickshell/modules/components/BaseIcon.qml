import QtQuick
import QtQuick.Layouts
import Quickshell
import qs

RowLayout {
    id: root

    // Icon (Core)
    property string icon: ""
    property int size: Theme.typography.size.medium
    property alias iconSize: root.size
    property color color: Theme.colors.text
    property alias iconColor: root.color
    property real rotation: 0
    // Text (Optional)
    property string text: ""
    property color textColor: color
    property int textSize: Theme.typography.size.base
    property int textWeight: Theme.typography.weights.normal
    // Variable Font Properties
    property bool fill: false
    property int weight: 400
    property int grade: 0
    // Fallback Logic
    property bool allowFallback: true
    property bool showFallback: allowFallback && icon === "" && text !== ""
    property string fallbackChar: text !== "" ? text.charAt(0).toUpperCase() : "?"
    property color fallbackBgColor: Theme.colors.background
    property int fallbackRadius: Math.max(2, Theme.geometry.radius * 0.5)
    property bool boxed: false

    // Layout
    spacing: text !== "" ? Theme.geometry.spacing.medium : 0
    implicitHeight: size

    // Fallback Background
    Rectangle {
        visible: (root.showFallback && root.icon === "") || root.boxed
        Layout.preferredWidth: root.size
        Layout.preferredHeight: root.size
        radius: root.fallbackRadius
        color: root.fallbackBgColor

        BaseText {
            anchors.centerIn: parent
            text: root.boxed ? root.icon : root.fallbackChar
            color: root.color
            pixelSize: root.size * 0.6
            weight: Theme.typography.weights.bold
            font.family: root.boxed ? Theme.typography.iconFamily : Theme.typography.family
        }

    }

    BaseText {
        id: iconElement

        visible: root.icon !== "" && !root.showFallback && !root.boxed
        text: root.icon
        font.pixelSize: root.size
        color: root.color
        font.family: Theme.typography.iconFamily
        rotation: root.rotation
        font.variableAxes: {
            "FILL": root.fill ? 1 : 0,
            "wght": root.weight,
            "GRAD": root.grade
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: root.size
        Layout.preferredHeight: root.size
    }

    BaseText {
        id: labelElement

        visible: root.text !== ""
        text: root.text
        color: root.textColor
        pixelSize: root.textSize
        weight: root.textWeight
        Layout.alignment: Qt.AlignVCenter
        Layout.fillWidth: true
        elide: Text.ElideRight
    }

}
