import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs

BasePopoutWindow {
    id: root

    property int currentTabIndex: 0

    // Helper to switch tabs externally (e.g. from bar)
    function switchToTab(index) {
        root.currentTabIndex = index;
    }

    panelNamespace: "quickshell:system-control-popout"

    body: ScrollView {
        implicitWidth: 600
        implicitHeight: Math.min(800, mainLayout.implicitHeight)
        contentWidth: availableWidth
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        ColumnLayout {
            id: mainLayout

            width: parent.width
            spacing: Theme.geometry.spacing.large

            // --- Header Section (Tabs) ---
            BaseBlock {
                id: tabBlock

                Layout.fillWidth: true
                padding: 4
                blockRadius: Theme.geometry.radius

                BaseMultiButton {
                    id: multiButton

                    model: [{
                        "text": "Quick Settings",
                        "icon": "settings"
                    }, {
                        "text": "Bluetooth",
                        "icon": "bluetooth"
                    }, {
                        "text": "Network",
                        "icon": "wifi"
                    }]
                    selectedIndex: root.currentTabIndex
                    buttonCustomRadius: tabBlock.blockRadius - tabBlock.padding
                    onButtonClicked: (index) => {
                        root.currentTabIndex = index;
                    }
                }

            }

            // --- Body / Content Stack ---
            StackLayout {
                id: mainStack

                Layout.fillWidth: true
                currentIndex: root.currentTabIndex
                Layout.preferredHeight: currentIndex >= 0 ? children[currentIndex].implicitHeight : 0

                // Quick Settings View
                ColumnLayout {
                    id: quickSettingsView

                    spacing: Theme.geometry.spacing.large
                    Layout.fillWidth: true

                    BaseBlock {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        BaseSlider {
                            id: brightnessSlider

                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            trackHeight: 38
                            icon: "brightness_medium"
                            suffix: Math.round(Display.brightness * 100)
                            iconColor: Theme.colors.text
                            suffixColor: Theme.colors.text
                            iconSize: Theme.dimensions.iconMedium
                            fontSize: Theme.typography.size.base
                            from: 0
                            to: 1
                            stepSize: 0.01
                            onValueChangedByUser: Display.setBrightness(value)

                            Binding on value {
                                value: Display.brightness
                                when: !brightnessSlider.pressed
                                restoreMode: Binding.RestoreBinding
                            }

                        }

                    }

                    // --- QUICK ACTIONS (Power Profile + Battery) ---
                    BaseBlock {
                        id: quickActionsRow
                        Layout.fillWidth: true
                        padding: 6
                        blockRadius: Theme.geometry.radius

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.geometry.spacing.large

                            // Power Profile Selector
                            BaseMultiButton {
                                id: profileSelector
                                Layout.fillWidth: true
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
                                buttonCustomRadius: quickActionsRow.blockRadius - quickActionsRow.padding
                                onButtonClicked: (index) => {
                                    var profiles = ["power-saver", "balanced", "performance"];
                                    Battery.setPowerProfile(profiles[index]);
                                }
                            }

                            // Battery Reporting (Right side)
                            RowLayout {
                                spacing: Theme.geometry.spacing.medium
                                visible: Battery.hasBattery
                                Layout.alignment: Qt.AlignVCenter

                                BaseIcon {
                                    icon: Battery.batteryIcon
                                    size: Theme.dimensions.iconLarge
                                    color: Battery.batteryColor
                                }

                                ColumnLayout {
                                    spacing: 0
                                    Layout.alignment: Qt.AlignVCenter

                                    BaseText {
                                        text: Battery.percentage + "%"
                                        pixelSize: Theme.typography.size.large
                                        weight: Theme.typography.weights.bold
                                    }

                                    BaseText {
                                        text: Battery.timeRemaining
                                        color: Theme.colors.muted
                                        pixelSize: Theme.typography.size.small
                                        visible: Battery.timeRemaining !== ""
                                    }
                                }

                                // Add a small spacer to prevent it from hugging the edge too tightly if needed
                                Item { Layout.preferredWidth: 4 }
                            }
                        }
                    }

                    BaseBlock {
                        id: powerSection

                        Layout.fillWidth: true

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.geometry.spacing.dynamicPadding

                            BaseButton {
                                Layout.fillWidth: true
                                icon: "power_settings_new"
                                iconSize: Theme.dimensions.iconLarge
                                normalColor: "transparent"
                                hoverEnabled: false
                                hoverRotate: true
                                onClicked: {
                                    root.close();
                                    Power.shutdown();
                                }
                            }

                            BaseButton {
                                Layout.fillWidth: true
                                icon: "restart_alt"
                                iconSize: Theme.dimensions.iconLarge
                                normalColor: "transparent"
                                hoverEnabled: false
                                hoverRotate: true
                                onClicked: {
                                    root.close();
                                    Power.reboot();
                                }
                            }

                            BaseButton {
                                Layout.fillWidth: true
                                icon: "bedtime"
                                iconSize: Theme.dimensions.iconLarge
                                normalColor: "transparent"
                                hoverEnabled: false
                                hoverRotate: true
                                onClicked: {
                                    root.close();
                                    Power.suspend();
                                }
                            }

                            BaseButton {
                                Layout.fillWidth: true
                                icon: "logout"
                                iconSize: Theme.dimensions.iconLarge
                                normalColor: "transparent"
                                hoverEnabled: false
                                hoverRotate: true
                                onClicked: {
                                    root.close();
                                    Power.logout();
                                }
                            }

                            BaseButton {
                                Layout.fillWidth: true
                                icon: "settings_suggest"
                                iconSize: Theme.dimensions.iconLarge
                                normalColor: "transparent"
                                hoverEnabled: false
                                hoverRotate: true
                                onClicked: {
                                    root.close();
                                    Power.rebootToBios();
                                }
                            }

                        }

                    }

                }

                // Bluetooth Tab
                BluetoothContent {
                    Layout.fillWidth: true
                }

                // Network Tab
                NetworkContent {
                    Layout.fillWidth: true
                }



            }

        }

    }

}
