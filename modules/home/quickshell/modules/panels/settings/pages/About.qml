import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs

SettingsPage {
    id: root


    property string githubUrl: "https://github.com/goon/nixos"
    padding: Theme.geometry.spacing.dynamicPadding

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Theme.geometry.spacing.large

        // Project Header
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.geometry.spacing.medium
                Layout.alignment: Qt.AlignHCenter

                BaseText {
                    text: "Yet Another Quickshell"
                    weight: Theme.typography.weights.bold
                    pixelSize: Theme.typography.size.display * 0.5
                    color: Theme.colors.primary
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20

                    BaseButton {
                        text: "GitHub"
                        textSize: Theme.typography.size.base
                        textColor: Theme.colors.text
                        paddingHorizontal: 20
                        paddingVertical: 10
                        normalColor: Theme.colors.surface
                        hoverGradient: true
                        borderColor: Theme.colors.border
                        borderWidth: 1
                        onClicked: Qt.openUrlExternally(root.githubUrl)
                    }

                    BaseButton {
                        text: "Restart Shell"
                        textSize: Theme.typography.size.base
                        textColor: Theme.colors.text
                        paddingHorizontal: 20
                        paddingVertical: 10
                        normalColor: Theme.colors.surface
                        hoverGradient: true
                        borderColor: Theme.colors.border
                        borderWidth: 1
                        onClicked: ProcessService.run(["sh", "-c", "nohup { pkill -9 quickshell; sleep 0.1; quickshell; } > /dev/null 2>&1 &"])
                    }
                }
            }

        BaseSeparator {
            Layout.fillWidth: true
        }

        // Hardware Information
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.geometry.spacing.medium

            BaseText {
                text: "Hardware Information"
                weight: Theme.typography.weights.bold
                color: Theme.colors.primary
                pixelSize: Theme.typography.size.large
                Layout.topMargin: Theme.geometry.spacing.small
            }

            BaseText {
                text: "Detailed overview of your current system specifications and environment."
                color: Theme.colors.text
                pixelSize: Theme.typography.size.medium
                Layout.fillWidth: true
                Layout.preferredWidth: 0
                Layout.bottomMargin: Theme.geometry.spacing.small
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.geometry.spacing.small

                // OS
                BaseBlock {
                    id: osBlock
                    Layout.fillWidth: true
                    padding: Theme.geometry.spacing.dynamicPadding
                    backgroundColor: Theme.alpha(Theme.colors.appBackground, 0.5)
                    clickable: true
                    
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: Theme.geometry.spacing.medium

                        BaseIcon {
                            icon: "cloud"
                            size: Theme.dimensions.iconBase
                            color: osBlock.containsMouse ? Theme.colors.textLighter : Theme.colors.primary
                        }

                        BaseText {
                            text: "OS"
                            color: osBlock.containsMouse ? Theme.colors.textLighter : Theme.colors.text
                            pixelSize: Theme.typography.size.medium
                        }

                        Item { Layout.fillWidth: true }

                        BaseText {
                            text: SystemInfo.osName || "Unknown"
                            color: osBlock.containsMouse ? Theme.colors.textLighter : Theme.colors.text
                            pixelSize: Theme.typography.size.base
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }

                // Kernel
                BaseBlock {
                    id: kernelBlock
                    Layout.fillWidth: true
                    padding: Theme.geometry.spacing.dynamicPadding
                    backgroundColor: Theme.alpha(Theme.colors.appBackground, 0.5)
                    clickable: true

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: Theme.geometry.spacing.medium

                        BaseIcon {
                            icon: "terminal"
                            size: Theme.dimensions.iconBase
                            color: kernelBlock.containsMouse ? Theme.colors.textLighter : Theme.colors.primary
                        }

                        BaseText {
                            text: "Kernel"
                            color: kernelBlock.containsMouse ? Theme.colors.textLighter : Theme.colors.text
                            pixelSize: Theme.typography.size.medium
                        }

                        Item { Layout.fillWidth: true }

                        BaseText {
                            text: (SystemInfo.kernelVersion ? SystemInfo.kernelVersion.split('-')[0] : "Unknown")
                            color: kernelBlock.containsMouse ? Theme.colors.textLighter : Theme.colors.text
                            pixelSize: Theme.typography.size.base
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }

                // Uptime
                BaseBlock {
                    id: uptimeBlock
                    Layout.fillWidth: true
                    padding: Theme.geometry.spacing.dynamicPadding
                    backgroundColor: Theme.alpha(Theme.colors.appBackground, 0.5)
                    clickable: true

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: Theme.geometry.spacing.medium

                        BaseIcon {
                            icon: "schedule"
                            size: Theme.dimensions.iconBase
                            color: uptimeBlock.containsMouse ? Theme.colors.textLighter : Theme.colors.primary
                        }

                        BaseText {
                            text: "Uptime"
                            color: uptimeBlock.containsMouse ? Theme.colors.textLighter : Theme.colors.text
                            pixelSize: Theme.typography.size.medium
                        }

                        Item { Layout.fillWidth: true }

                        BaseText {
                            text: SystemInfo.uptime
                            color: uptimeBlock.containsMouse ? Theme.colors.textLighter : Theme.colors.text
                            pixelSize: Theme.typography.size.base
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }

                // Compositor
                BaseBlock {
                    id: compositorBlock
                    Layout.fillWidth: true
                    padding: Theme.geometry.spacing.dynamicPadding
                    backgroundColor: Theme.alpha(Theme.colors.appBackground, 0.5)
                    clickable: true

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: Theme.geometry.spacing.medium

                        BaseIcon {
                            icon: "layers"
                            size: Theme.dimensions.iconBase
                            color: compositorBlock.containsMouse ? Theme.colors.textLighter : Theme.colors.primary
                        }

                        BaseText {
                            text: "Compositor"
                            color: compositorBlock.containsMouse ? Theme.colors.textLighter : Theme.colors.text
                            pixelSize: Theme.typography.size.medium
                        }

                        Item { Layout.fillWidth: true }

                        BaseText {
                            text: (SystemInfo.de !== "N/A" ? SystemInfo.de : SystemInfo.wm) || "Unknown"
                            color: compositorBlock.containsMouse ? Theme.colors.textLighter : Theme.colors.text
                            pixelSize: Theme.typography.size.base
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }

                // Memory
                BaseBlock {
                    id: memBlock
                    Layout.fillWidth: true
                    padding: Theme.geometry.spacing.dynamicPadding
                    backgroundColor: Theme.alpha(Theme.colors.appBackground, 0.5)
                    clickable: true

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: Theme.geometry.spacing.medium

                        BaseIcon {
                            icon: "memory"
                            size: Theme.dimensions.iconBase
                            color: memBlock.containsMouse ? Theme.colors.textLighter : Theme.colors.primary
                        }

                        BaseText {
                            text: "Memory"
                            color: memBlock.containsMouse ? Theme.colors.textLighter : Theme.colors.text
                            pixelSize: Theme.typography.size.medium
                        }

                        Item { Layout.fillWidth: true }

                        BaseText {
                            text: Stats.totalRam || "..."
                            color: memBlock.containsMouse ? Theme.colors.textLighter : Theme.colors.text
                            pixelSize: Theme.typography.size.base
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }

                // CPU
                BaseBlock {
                    id: cpuBlock
                    Layout.fillWidth: true
                    padding: Theme.geometry.spacing.dynamicPadding
                    backgroundColor: Theme.alpha(Theme.colors.appBackground, 0.5)
                    clickable: true

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.geometry.spacing.medium

                        BaseIcon {
                            icon: "developer_board"
                            size: Theme.dimensions.iconBase
                            color: cpuBlock.containsMouse ? Theme.colors.textLighter : Theme.colors.primary
                        }

                        BaseText {
                            text: "CPU"
                            color: cpuBlock.containsMouse ? Theme.colors.textLighter : Theme.colors.text
                            pixelSize: Theme.typography.size.medium
                        }

                        Item { Layout.fillWidth: true }

                        BaseText {
                            text: SystemInfo.cpuModel || "..."
                            color: cpuBlock.containsMouse ? Theme.colors.textLighter : Theme.colors.text
                            pixelSize: Theme.typography.size.base
                            horizontalAlignment: Text.AlignRight
                            Layout.maximumWidth: 350
                            elide: Text.ElideLeft
                        }
                    }
                }

                // GPU
                BaseBlock {
                    id: gpuBlock
                    Layout.fillWidth: true
                    padding: Theme.geometry.spacing.dynamicPadding
                    backgroundColor: Theme.alpha(Theme.colors.appBackground, 0.5)
                    clickable: true

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.geometry.spacing.medium

                        BaseIcon {
                            icon: "videogame_asset"
                            size: Theme.dimensions.iconBase
                            color: gpuBlock.containsMouse ? Theme.colors.textLighter : Theme.colors.primary
                        }

                        BaseText {
                            text: "GPU"
                            color: gpuBlock.containsMouse ? Theme.colors.textLighter : Theme.colors.text
                            pixelSize: Theme.typography.size.medium
                        }

                        Item { Layout.fillWidth: true }

                        BaseText {
                            text: SystemInfo.gpuModel || "..."
                            color: gpuBlock.containsMouse ? Theme.colors.textLighter : Theme.colors.text
                            pixelSize: Theme.typography.size.base
                            horizontalAlignment: Text.AlignRight
                            Layout.maximumWidth: 350
                            elide: Text.ElideLeft
                        }
                    }
                }

            }

            // Displays
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.geometry.spacing.small
                visible: Quickshell.screens.length > 0

                Repeater {
                    model: Quickshell.screens

                    BaseBlock {
                        id: displayBlock
                        Layout.fillWidth: true
                        padding: Theme.geometry.spacing.dynamicPadding
                        backgroundColor: Theme.alpha(Theme.colors.appBackground, 0.5)
                        clickable: true

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.geometry.spacing.medium

                            BaseIcon {
                                icon: "desktop_windows"
                                size: Theme.dimensions.iconBase
                                color: displayBlock.containsMouse ? Theme.colors.textLighter : Theme.colors.primary
                            }

                            BaseText {
                                text: (modelData.name || "Display")
                                color: displayBlock.containsMouse ? Theme.colors.textLighter : Theme.colors.text
                                pixelSize: Theme.typography.size.medium
                            }

                            Item { Layout.fillWidth: true }

                            BaseText {
                                text: modelData.width + "x" + modelData.height
                                color: displayBlock.containsMouse ? Theme.colors.textLighter : Theme.colors.text
                                pixelSize: Theme.typography.size.base
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }
            }

        }

    }

}
