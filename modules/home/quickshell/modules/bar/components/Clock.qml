import QtQuick
import QtQuick.Layouts
import Quickshell
import qs

BaseBlock {
    id: root
    
    Layout.alignment: Qt.AlignVCenter
    Layout.fillWidth: false
    paddingHorizontal: Theme.geometry.spacing.dynamicPadding
    paddingVertical: 0
    implicitHeight: Theme.dimensions.barItemHeight
    hoverEnabled: false
    clickable: true
    
    Component.onCompleted: PopoutService.clockItem = root
    Component.onDestruction: PopoutService.clockItem = null

    onClicked: {
        PopoutService.toggleCalendarPopout();
    }

    // Now supported natively by BaseBlock
    onMiddleClicked: {
        Weather.fetchWeather();
    }

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

    // Unified content layout - providing implicit size to BaseBlock correctly
    RowLayout {
        id: layout
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        spacing: Theme.geometry.spacing.medium

        // Time with bold hour
        BaseText {
            text: "<b>" + Qt.formatDateTime(systemClock.date, "hh") + "</b>" + " " + Qt.formatDateTime(systemClock.date, "mm")
            textFormat: Text.RichText
            pixelSize: Theme.typography.size.medium
            weight: Theme.typography.weights.normal
            color: root.containsMouse ? Theme.colors.primary : Theme.colors.text
        }

        BaseSeparator {
            orientation: BaseSeparator.Vertical
            fill: false
            thickness: 1
            Layout.preferredHeight: Theme.dimensions.iconSmall
            Layout.preferredWidth: 1
            opacity: 0.3
            color: Theme.colors.text
        }

        // Temperature
        BaseText {
            text: Weather.temperature
            pixelSize: Theme.typography.size.medium
            weight: Theme.typography.weights.normal
            color: root.containsMouse ? Theme.colors.primary : Theme.colors.text
        }
    }
}
