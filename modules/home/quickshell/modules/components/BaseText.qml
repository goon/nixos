import QtQuick.Effects
import QtQuick
import Quickshell
import qs

Text {
    id: root

    // Convenience properties for common overrides
    property alias pixelSize: root.font.pixelSize
    property alias bold: root.font.bold
    property alias italic: root.font.italic
    property alias family: root.font.family
    // Centralized defaults from Theme
    property color normalColor: Theme.colors.text
    property color hoverColor: Theme.colors.muted
    // Hover support
    property bool hoverEnabled: false
    readonly property alias containsMouse: mouseArea.containsMouse
    property alias mouseArea: mouseArea
    // Shadow support
    property bool shadow: false
    property color shadowColor: Theme.effects.shadow.color
    property int shadowRadius: Theme.effects.shadow.radius
    property int shadowSamples: Theme.effects.shadow.samples
    property int shadowOffsetX: Theme.effects.shadow.offsetX
    property int shadowOffsetY: Theme.effects.shadow.offsetY
    property int weight: Theme.typography.weights.normal

    signal clicked()
    signal pressedSignal()
    signal released()

    color: (hoverEnabled && mouseArea.containsMouse) ? hoverColor : normalColor
    family: Theme.typography.family
    pixelSize: Theme.typography.size.base
    font.weight: root.weight
    wrapMode: Text.WordWrap
    layer.enabled: shadow

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        enabled: root.hoverEnabled
        hoverEnabled: root.hoverEnabled
        cursorShape: root.hoverEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: (mouse) => {
            return root.clicked();
        }
        onPressed: root.pressedSignal()
        onReleased: root.released()
    }

    Behavior on color {
        BaseAnimation {
            duration: Theme.animations.fast
        }
    }

    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: root.shadowColor
        shadowBlur: root.shadowRadius / 20.0
        shadowHorizontalOffset: root.shadowOffsetX
        shadowVerticalOffset: root.shadowOffsetY
    }

}
