import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs

BasePopoutWindow {
    id: root

    panelNamespace: "quickshell:calendar-popout"

    RowLayout {
        anchors.fill: parent
        spacing: Theme.geometry.spacing.large

        BaseBlock {
            id: cal
            Layout.fillWidth: true
            Layout.fillHeight: true

            Item {
                id: calendarWidget

                Layout.fillWidth: true
                Layout.fillHeight: true
                implicitWidth: contentColumn.width
                implicitHeight: contentColumn.height

                Column {
                    id: contentColumn
                    anchors.centerIn: parent
                    spacing: Theme.geometry.spacing.medium
                    width: Theme.dimensions.calendarBlockWidth

                    // Month navigation header
                    Item {
                        id: navHeader

                        width: parent.width
                        height: 60

                        // Previous month button
                        BaseButton {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: Theme.dimensions.calendarCellSize
                            height: parent.height
                            icon: "chevron_left"
                            iconSize: Theme.dimensions.iconBase
                            normalColor: Theme.colors.transparent
                            hoverColor: Theme.colors.surface
                            scale: pressed ? 0.92 : (containsMouse ? 1.05 : 1.0)
                            onClicked: {
                                gridContainer.direction = -1;
                                Calendar.changeMonth(-1);
                            }
                        }

                        // Centered overlapping text
                        Item {
                            id: headerContainer
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width - (Theme.dimensions.calendarCellSize * 2)
                            height: parent.height
                            scale: headerMouseArea.pressed ? 0.98 : 1.0

                            Behavior on scale { BaseAnimation { speed: "fast" } }

                            MouseArea {
                                id: headerMouseArea
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var now = new Date();
                                    var currentVal = Calendar.displayYear * 12 + Calendar.displayMonth;
                                    var targetVal = now.getFullYear() * 12 + now.getMonth();

                                    if (currentVal !== targetVal) {
                                        gridContainer.direction = (targetVal > currentVal) ? 1 : -1;
                                        Calendar.resetToCurrentMonth();
                                    }
                                }
                            }

                            BaseText {
                                id: monthLabel
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.horizontalCenterOffset: -20
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.verticalCenterOffset: -8
                                color: Theme.colors.text
                                weight: Theme.typography.weights.bold
                                pixelSize: Theme.typography.size.display * 0.6 // Approximate for 28px
                                text: Calendar.monthNames[Calendar.displayMonth].toUpperCase()
                                z: 1
                                opacity: 1.0
                            }

                            BaseText {
                                id: yearLabel
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.horizontalCenterOffset: 30
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.verticalCenterOffset: 12
                                color: Theme.colors.primary
                                weight: Theme.typography.weights.bold
                                pixelSize: Theme.typography.size.display * 0.75 // Approximate for 36px
                                text: Calendar.displayYear
                                z: 2
                                opacity: 0.85

                                // Cutout Effect
                                shadow: true
                                shadowColor: Theme.colors.surface
                                shadowRadius: 10
                            }
                        }

                        // Next month button
                        BaseButton {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: Theme.dimensions.calendarCellSize
                            height: parent.height
                            icon: "chevron_right"
                            iconSize: Theme.dimensions.iconBase
                            normalColor: Theme.colors.transparent
                            hoverColor: Theme.colors.surface
                            scale: pressed ? 0.92 : (containsMouse ? 1.05 : 1.0)
                            onClicked: {
                                gridContainer.direction = 1;
                                Calendar.changeMonth(1);
                            }
                        }
                    }

                    // Day headers (Sun, Mon, Tue, etc.)
                    Row {
                        id: dayHeaders

                        width: parent.width
                        spacing: Theme.geometry.spacing.small

                        Repeater {
                            model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

                            Item {
                                width: (parent.width - (6 * Theme.geometry.spacing.small)) / 7
                                implicitHeight: headerText.implicitHeight + Theme.geometry.spacing.small
                                height: implicitHeight

                                BaseText {
                                    id: headerText

                                    anchors.centerIn: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    color: Theme.colors.muted
                                    text: modelData
                                }
                            }
                        }
                    }

                    Item {
                        id: gridContainer
                        width: parent.width
                        implicitHeight: grid.height
                        clip: true

                        property int direction: 0

                        onDirectionChanged: {
                            if (direction !== 0) {
                                slideAnim.restart();
                                direction = 0;
                            }
                        }

                        SequentialAnimation {
                            id: slideAnim
                            ParallelAnimation {
                                BaseAnimation {
                                    targets: [grid, monthLabel, yearLabel]
                                    property: "x"
                                    from: 0
                                    to: -gridContainer.direction * 20
                                    speed: "fast"
                                    easing.type: Easing.OutCubic
                                }
                                BaseAnimation {
                                    targets: [grid, monthLabel, yearLabel]
                                    property: "opacity"
                                    from: monthLabel.opacity
                                    to: 0
                                    speed: "fast"
                                }
                            }
                            PropertyAction { targets: [grid, monthLabel, yearLabel]; property: "x"; value: gridContainer.direction * 20 }
                            ParallelAnimation {
                                BaseAnimation {
                                    targets: [grid, monthLabel, yearLabel]
                                    to: 0
                                    property: "x"
                                    speed: "fast"
                                    easing.type: Easing.OutBack
                                }
                                BaseAnimation {
                                    targets: [grid, monthLabel, yearLabel]
                                    property: "opacity"
                                    to: 1
                                    speed: "fast"
                                }
                            }
                        }

                        Grid {
                            id: grid

                            width: parent.width
                            columns: 7
                            spacing: Theme.geometry.spacing.small

                            Repeater {
                                model: Calendar.calendarDays

                                BaseButton {
                                    id: dayButton
                                    required property var modelData

                                    width: (parent.width - (6 * Theme.geometry.spacing.small)) / 7
                                    implicitHeight: dayText.implicitHeight + Theme.geometry.spacing.medium
                                    height: implicitHeight
                                    
                                    normalColor: Theme.colors.transparent
                                    hoverColor: modelData.isCurrentMonth ? Theme.alpha(Theme.colors.text, 0.05) : Theme.colors.transparent
                                    activeColor: Theme.alpha(Theme.colors.text, 0.1)
                                    
                                    scale: pressed ? 0.95 : (containsMouse ? 1.02 : 1.0)
                                    
                                    // Today/Selection Highlight (Matches LauncherItemDelegate)
                                    Item {
                                        anchors.fill: parent
                                        visible: modelData.isToday
                                        
                                        // 1. Premium Selection Gradient Border
                                        Rectangle {
                                            anchors.fill: parent
                                            radius: parent.parent.radius
                                            gradient: Gradient {
                                                orientation: Gradient.Horizontal
                                                GradientStop { position: 0; color: Theme.colors.primary }
                                                GradientStop { position: 1; color: Theme.colors.secondary }
                                            }
                                        }

                                        // 2. Inner "Cutout" and Selection Tint
                                        Rectangle {
                                            anchors.fill: parent
                                            anchors.margins: 1.5
                                            radius: parent.parent.radius - 1.5
                                            color: Theme.colors.surface
                                            
                                            Rectangle {
                                                anchors.fill: parent
                                                radius: parent.radius
                                                // Combine permanent tint with mouse hover feedback
                                                color: dayButton.containsMouse ? Qt.alpha(Theme.colors.primary, 0.12) : Qt.alpha(Theme.colors.primary, 0.08)
                                                Behavior on color { BaseAnimation { speed: "fast" } }
                                            }
                                        }

                                        // 3. Permanent Inner Glass Highlight
                                        Rectangle {
                                            anchors.fill: parent
                                            anchors.margins: 1
                                            radius: parent.parent.radius - 1
                                            gradient: Gradient {
                                                GradientStop { position: 0.0; color: Theme.alpha(Theme.colors.text, 0.05) }
                                                GradientStop { position: 1.0; color: Theme.colors.transparent }
                                            }
                                        }
                                    }

                                    // Hover glass effect
                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.margins: 1
                                        radius: parent.radius - 1
                                        gradient: Gradient {
                                            GradientStop { position: 0.0; color: Theme.alpha(Theme.colors.text, 0.05) }
                                            GradientStop { position: 1.0; color: Theme.colors.transparent }
                                        }
                                        visible: dayButton.containsMouse && !modelData.isToday
                                    }

                                    enabled: modelData.isCurrentMonth

                                    BaseText {
                                        id: dayText

                                        anchors.centerIn: parent
                                        color: {
                                            if (!modelData.isCurrentMonth) return Theme.colors.muted;
                                            if (modelData.isToday) return Theme.colors.text; // Light text on selection
                                            return dayButton.containsMouse ? Theme.colors.text : Theme.colors.text;
                                        }
                                        pixelSize: Theme.typography.size.medium - 1
                                        weight: modelData.isToday ? Theme.typography.weights.bold : Theme.typography.weights.normal
                                        text: modelData.day < 10 ? "0" + modelData.day : modelData.day
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        BaseBlock {
            id: weather
            Layout.preferredWidth: 320
            Layout.fillWidth: false
            Layout.fillHeight: true

            ColumnLayout {
                id: weatherWidget

                readonly property bool isDay: Weather.isDay
                readonly property int code: Weather.weatherCode
                readonly property string temp: Weather.temperature

                function getIcon(code, isDay) {
                    if (code === 0)
                        return isDay ? "clear_day" : "clear_night";
                    if (code >= 1 && code <= 3)
                        return isDay ? "partly_cloudy_day" : "partly_cloudy_night";
                    if (code >= 45 && code <= 48)
                        return "foggy";
                    if (code >= 51 && code <= 67)
                        return "rainy";
                    if (code >= 71 && code <= 77)
                        return "weather_snowy";
                    if (code >= 80 && code <= 82)
                        return "rainy";
                    if (code >= 85 && code <= 86)
                        return "weather_snowy";
                    if (code >= 95 && code <= 99)
                        return "thunderstorm";
                    return "question_mark";
                }

                function getDayName(index) {
                    if (!Weather.dailyForecast || !Weather.dailyForecast.time) return "";
                    const date = new Date(Weather.dailyForecast.time[index]);
                    const days = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"];
                    return days[date.getDay()];
                }

                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Theme.geometry.spacing.medium

                // Current Weather Top Section
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.geometry.spacing.medium

                    BaseIcon {
                        icon: weatherWidget.getIcon(weatherWidget.code, weatherWidget.isDay)
                        size: Theme.dimensions.iconExtraLarge
                        color: Theme.colors.primary
                        Layout.alignment: Qt.AlignVCenter
                    }

                    BaseText {
                        text: weatherWidget.temp
                        font.pixelSize: Theme.typography.size.display
                        weight: Theme.typography.weights.bold
                        color: Theme.colors.text
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item { Layout.fillWidth: true }

                    BaseText {
                        text: Preferences.weatherLocationName.split(",")[0]
                        font.pixelSize: Theme.typography.size.large
                        color: Theme.colors.text
                        visible: Preferences.weatherShowLocation && Preferences.weatherLocationName !== ""
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                // Horizontal Separator
                BaseSeparator {
                    orientation: BaseSeparator.Horizontal
                    Layout.fillWidth: true
                    Layout.topMargin: Theme.geometry.spacing.medium
                    Layout.bottomMargin: Theme.geometry.spacing.medium
                }

                // 5-Day Forecast
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Theme.geometry.spacing.medium

                    Repeater {
                        model: Weather.dailyForecast ? Math.min(5, Weather.dailyForecast.time.length) : 0
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Theme.geometry.spacing.medium

                            BaseText {
                                Layout.alignment: Qt.AlignHCenter
                                text: weatherWidget.getDayName(index)
                                font.pixelSize: Theme.typography.size.medium
                                color: Theme.colors.muted
                                weight: Theme.typography.weights.bold
                            }

                            BaseIcon {
                                Layout.alignment: Qt.AlignHCenter
                                icon: weatherWidget.getIcon(Weather.dailyForecast.weathercode[index], true)
                                size: Theme.dimensions.iconExtraLarge
                                color: Theme.colors.primary
                            }

                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 4
                                BaseText {
                                    text: Math.round(Weather.dailyForecast.temperature_2m_max[index]) + "°"
                                    font.pixelSize: Theme.typography.size.medium
                                    color: Theme.colors.text
                                    weight: Theme.typography.weights.bold
                                }
                                BaseText {
                                    text: Math.round(Weather.dailyForecast.temperature_2m_min[index]) + "°"
                                    font.pixelSize: Theme.typography.size.small
                                    color: Theme.colors.muted
                                }
                            }
                        }
                    }
                }

                // Error and Refresh
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: Weather.error !== ""
                    spacing: 4

                    BaseButton {
                        Layout.alignment: Qt.AlignHCenter
                        width: 80
                        text: "Refresh"
                        icon: "refresh"
                        onClicked: Weather.fetchWeather()
                    }

                    BaseText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: Weather.error
                        font.pixelSize: Theme.typography.size.small
                        color: Theme.colors.error
                    }
                }
            }
        }
    }
}
