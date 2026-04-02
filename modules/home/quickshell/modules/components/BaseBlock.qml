import ".."
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import qs

Rectangle {
    id: root

    // Styling
    // Styling
    property color backgroundColor: Theme.alpha(Theme.colors.surface, Theme.blur.surfaceOpacity)
    property color hoverColor: Theme.colors.transparent
    property bool borderEnabled: true
    property color borderColor: Theme.colors.background
    property int borderWidth: 0
    property int blockRadius: Theme.geometry.radius
    // Header
    property string title: ""
    property string icon: ""
    property color iconColor: Theme.colors.primary
    property Component header: null
    property Component headerItem: null
    // Layout
    property real padding: Theme.geometry.spacing.dynamicPadding
    property real paddingHorizontal: padding
    property real paddingVertical: padding
    property real spacing: Theme.geometry.spacing.medium
    // Interactivity
    property bool clickable: false
    property bool hoverEnabled: true
    readonly property alias containsMouse: mouseArea.containsMouse
    readonly property alias pressed: mouseArea.pressed
    // Internal layout control
    default property alias contentData: contentContainer.data

    signal clicked()
    signal rightClicked()
    signal middleClicked()
    signal pressedSignal()
    signal releasedSignal()

    Layout.fillWidth: true
    implicitWidth: mainLayout.implicitWidth + (paddingHorizontal * 2)
    implicitHeight: mainLayout.implicitHeight + (paddingVertical * 2)
    color: backgroundColor
    radius: blockRadius
    border.color: borderEnabled ? borderColor : Theme.colors.transparent
    border.width: borderEnabled ? borderWidth : 0
    scale: (root.clickable && pressed) ? 0.98 : 1.0

    Behavior on scale {
        BaseAnimation {
            duration: Theme.animations.fast
        }
    }

    // State Layer
    Rectangle {
        id: stateLayer

        anchors.fill: parent
        radius: parent.radius
        color: {
            if (!root.hoverEnabled)
                return Theme.colors.transparent;

            if (root.hoverColor !== Theme.colors.transparent && mouseArea.containsMouse)
                return root.hoverColor;

            if (mouseArea.containsMouse)
                return Theme.colors.background;

            return Theme.colors.transparent;
        }

    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        enabled: root.clickable
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton)
                root.rightClicked();
            else if (mouse.button === Qt.MiddleButton)
                root.middleClicked();
            else
                root.clicked();
        }
        onPressed: (mouse) => {
            root.pressedSignal();
        }
        onReleased: root.releasedSignal()
    }

    ColumnLayout {
        id: mainLayout

        anchors.fill: parent
        anchors.leftMargin: root.paddingHorizontal
        anchors.rightMargin: root.paddingHorizontal
        anchors.topMargin: root.paddingVertical
        anchors.bottomMargin: root.paddingVertical
        spacing: root.spacing

        // Built-in Header
        RowLayout {
            visible: root.title !== "" || root.icon !== ""
            spacing: Theme.geometry.spacing.small
            Layout.fillWidth: true

            BaseIcon {
                visible: root.icon !== ""
                icon: root.icon
                color: root.iconColor
                size: Theme.geometry.spacing.medium + 2
            }

            BaseText {
                text: root.title
                weight: Theme.typography.weights.bold
                pixelSize: Theme.typography.size.large
                Layout.fillWidth: true
            }

            Loader {
                id: customHeaderItemLoader
                visible: root.headerItem !== null
                sourceComponent: root.headerItem
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            }

        }

        // Custom Header Component
        Loader {
            visible: root.header !== null
            sourceComponent: root.header
            Layout.fillWidth: true
        }

        ColumnLayout {
            id: contentContainer

            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: root.spacing
        }

    }


}
