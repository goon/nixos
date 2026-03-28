import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs

SettingsPage {
    id: root

    title: "System & External Services"

    GridLayout {
        columns: 2
        rowSpacing: Theme.geometry.spacing.dynamicPadding
        columnSpacing: Theme.geometry.spacing.dynamicPadding
        Layout.fillWidth: true

        BaseText {
            text: "Manage your system integration, localized services, and external application defaults."
            color: Theme.colors.text
            pixelSize: Theme.typography.size.medium
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            Layout.columnSpan: 2
            Layout.bottomMargin: Theme.geometry.spacing.small
        }

        // --- Weather ---
        BaseText {
            text: "Weather"
            weight: Theme.typography.weights.bold
            color: Theme.colors.primary
            pixelSize: Theme.typography.size.large
            Layout.columnSpan: 2
            Layout.topMargin: Theme.geometry.spacing.small
        }

        BaseText {
            text: "Location Name:"
            pixelSize: Theme.typography.size.medium
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            BaseInput {
                id: locationInput
                Layout.fillWidth: true
                implicitHeight: 42
                inputPadding: 10
                text: Preferences.weatherLocationName
                placeholderText: "Search location... (e.g. London)"
                onTextChanged: {
                    if (activeFocus)
                        searchTimer.restart();
                }
                onEditingFinished: {
                    Preferences.weatherLocationName = text;
                }
            }

            Timer {
                id: searchTimer
                interval: 500
                repeat: false
                onTriggered: Weather.searchLocation(locationInput.text)
            }

            // Search Results List
            Popup {
                id: resultsList
                y: locationInput.height + 2
                width: locationInput.width
                padding: 1
                visible: Weather.searchResults && Weather.searchResults.length > 0 && locationInput.activeFocus
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                
                property var input: locationInput
                property int maxVisibleItems: 10

                background: Rectangle {
                    color: Theme.colors.background
                    radius: Theme.geometry.radius
                    border.width: 0
                }

                contentItem: ListView {
                    id: resultsListView
                    implicitHeight: Math.min(contentHeight, 36 * resultsList.maxVisibleItems)
                    clip: true
                    model: Weather.searchResults
                    
                    delegate: ItemDelegate {
                        id: delegateRoot
                        width: resultsListView.width
                        height: 36
                        
                        property string fullName: modelData.name + (modelData.admin1 ? (", " + modelData.admin1) : "") + (modelData.country ? (", " + modelData.country) : "")

                        contentItem: Text {
                            text: delegateRoot.fullName
                            color: Theme.colors.text
                            font.family: Theme.typography.family
                            font.pixelSize: Theme.typography.size.base
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: Theme.geometry.spacing.dynamicPadding
                            rightPadding: Theme.geometry.spacing.dynamicPadding
                        }

                        background: Rectangle {
                            color: parent.highlighted || parent.hovered ? Theme.colors.text : Theme.colors.transparent
                            radius: Math.max(2, Theme.geometry.radius * 0.5)
                            anchors.fill: parent
                            anchors.margins: 2
                        }

                        onClicked: {
                            Preferences.weatherLat = modelData.latitude.toString();
                            Preferences.weatherLong = modelData.longitude.toString();
                            Preferences.weatherLocationName = fullName;
                            locationInput.text = fullName;
                            Weather.searchResults = []; // Clear results
                            locationInput.focus = false;
                            resultsList.close();
                        }
                    }

                    ScrollBar.vertical: BaseScrollBar {
                    }
                }
            }
            // Coordinates label
            BaseText {
                text: "Coordinates: " + Preferences.weatherLat + ", " + Preferences.weatherLong
                color: Theme.colors.text
                visible: Preferences.weatherLat && Preferences.weatherLong
            }
        }

        BaseText {
            text: "Show Location in Popout:"
            pixelSize: Theme.typography.size.medium
        }

        BaseSwitch {
            checked: Preferences.weatherShowLocation
            onToggled: Preferences.weatherShowLocation = checked
            Layout.alignment: Qt.AlignLeft
        }

        BaseSeparator {
            Layout.fillWidth: true
            Layout.columnSpan: 2
            Layout.topMargin: Theme.geometry.spacing.medium
            Layout.bottomMargin: Theme.geometry.spacing.medium
        }

        // --- External Services ---
        BaseText {
            text: "External Services"
            weight: Theme.typography.weights.bold
            color: Theme.colors.primary
            pixelSize: Theme.typography.size.large
            Layout.columnSpan: 2
            Layout.topMargin: Theme.geometry.spacing.large
        }

        BaseText { 
            text: "Web Search URL:" 
            pixelSize: Theme.typography.size.medium
        }
        BaseInput {
            Layout.fillWidth: true
            implicitHeight: 42
            inputPadding: 10
            text: Preferences.webSearchUrl
            placeholderText: "e.g. https://google.com/search?q="
            onEditingFinished: Preferences.webSearchUrl = text
        }

        BaseText { 
            text: "Terminal:" 
            pixelSize: Theme.typography.size.medium
        }
        BaseInput {
            id: terminalInput
            Layout.fillWidth: true
            implicitHeight: 42
            inputPadding: 10
            text: Preferences.terminal
            placeholderText: "e.g. alacritty"
            onEditingFinished: Preferences.terminal = text
        }
    }
}
