import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs

ColumnLayout {
    id: root
    spacing: Theme.geometry.spacing.large
    Layout.fillWidth: true

    // --- POWER PROFILE SELECTOR ---
    BaseBlock {
        id: profileSelector
        Layout.fillWidth: true
        padding: 4
        blockRadius: Theme.geometry.radius

        BaseMultiButton {
            model: [
                { text: "Power Saving" },
                { text: "Balanced" },
                { text: "Performance" }
            ]
            selectedIndex: {
                if (Battery.powerProfile === "power-saver") return 0;
                if (Battery.powerProfile === "balanced") return 1;
                return 2;
            }
            buttonCustomRadius: profileSelector.blockRadius - profileSelector.padding
            onButtonClicked: (index) => {
                var profiles = ["power-saver", "balanced", "performance"];
                Battery.setPowerProfile(profiles[index]);
            }
        }
    }

    // --- MAIN BATTERY SECTION ---
    BaseBlock {
        title: "Main Battery"
        icon: "battery_full"
        Layout.fillWidth: true
        visible: Battery.hasBattery

        ColumnLayout {
            spacing: Theme.geometry.spacing.medium
            Layout.fillWidth: true

            RowLayout {
                spacing: Theme.geometry.spacing.medium
                Layout.fillWidth: true

                BaseIcon {
                    icon: Battery.batteryIcon
                    size: Theme.dimensions.iconLarge
                    color: Battery.batteryColor
                }

                ColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true

                    BaseText {
                        text: Battery.percentage + "%"
                        pixelSize: Theme.typography.size.large
                        weight: Theme.typography.weights.bold
                    }

                    BaseText {
                        text: Battery.timeRemaining
                        color: Theme.colors.muted
                        visible: Battery.timeRemaining !== ""
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }
    }

    // --- CONNECTED DEVICES SECTION ---
    BaseBlock {
        title: "Connected Devices"
        Layout.fillWidth: true
        visible: Battery.connectedDevices.length > 0

        ColumnLayout {
            spacing: Theme.geometry.spacing.medium
            Layout.fillWidth: true

            Repeater {
                model: Battery.connectedDevices

                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: deviceItemCol.implicitHeight + 16
                    color: Theme.alpha(Theme.colors.surface, 0.5)
                    radius: Theme.geometry.radius

                    ColumnLayout {
                        id: deviceItemCol
                        anchors.fill: parent
                        anchors.margins: Theme.geometry.spacing.medium
                        spacing: Theme.geometry.spacing.small

                        RowLayout {
                            spacing: Theme.geometry.spacing.small
                            Layout.fillWidth: true

                            BaseIcon {
                                icon: modelData.icon
                                size: Theme.dimensions.iconMedium
                                color: Theme.colors.text
                            }

                            BaseText {
                                Layout.fillWidth: true
                                text: modelData.name
                                color: Theme.colors.text
                                elide: Text.ElideRight
                                weight: Theme.typography.weights.medium
                            }

                            BaseText {
                                text: modelData.percentage + "%"
                                color: modelData.percentage <= 20 ? Theme.colors.error : (modelData.percentage <= 40 ? Theme.colors.warning : Theme.colors.text)
                                weight: Theme.typography.weights.medium
                            }
                        }

                        // Progress bar
                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 8

                            Rectangle {
                                anchors.fill: parent
                                radius: height / 2
                                color: Theme.colors.background

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    width: parent.width * (modelData.percentage / 100)
                                    radius: height / 2
                                    gradient: Gradient {
                                        orientation: Gradient.Horizontal
                                        GradientStop { position: 0.0; color: Theme.colors.primary }
                                        GradientStop { position: 1.0; color: Theme.colors.secondary }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // No devices message
    BaseText {
        visible: !Battery.hasBattery && Battery.connectedDevices.length === 0
        text: "No battery devices found."
        color: Theme.colors.muted
        horizontalAlignment: Text.AlignHCenter
        Layout.fillWidth: true
        Layout.topMargin: 20
    }
}
