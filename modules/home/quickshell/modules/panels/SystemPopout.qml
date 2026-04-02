import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs

BasePopoutWindow {
    id: root

    panelNamespace: "quickshell:system-popout"

    // The BasePopoutWindow handles its own background, alignment, and padding based on the panelNamespace and edge.
    // The ScrollView's margins will now define the internal padding of the popout window's body.
    body: ScrollView {
        implicitWidth: 640
        contentWidth: availableWidth
        implicitHeight: col.implicitHeight
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        ColumnLayout {
            id: col
            width: parent.width
            spacing: Theme.geometry.spacing.large
            
            ColumnLayout {
                id: rootResources
                Layout.fillWidth: true
                spacing: Theme.geometry.spacing.large

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: Theme.geometry.spacing.large
                    rowSpacing: Theme.geometry.spacing.large
                    uniformCellWidths: true

                    // ROW 1
                    // CPU Block
                    BaseBlock {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 180
                        padding: 0
                        clip: true

                        opacity: (root.panelState === "Open" || root.panelState === "Opening") ? 1.0 : 0.0
                        transform: Translate { y: (root.panelState === "Open" || root.panelState === "Opening") ? 0 : 30 }
                        
                        Behavior on opacity { BaseAnimation { speed: "slow" } }
                        Behavior on transform { BaseAnimation { speed: "slow"; easing.type: Easing.OutCubic } }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 0

                            RowLayout {
                                property real dispCpu: Stats.currentCpu
                                Behavior on dispCpu { NumberAnimation { duration: 800; easing.type: Easing.OutQuint } }

                                Layout.fillWidth: true
                                Layout.topMargin: Theme.geometry.spacing.dynamicPadding
                                Layout.leftMargin: Theme.geometry.spacing.dynamicPadding
                                Layout.rightMargin: Theme.geometry.spacing.dynamicPadding
                                spacing: Theme.geometry.spacing.small

                                BaseText { text: "CPU"; weight: Theme.typography.weights.bold }
                                Item { Layout.fillWidth: true }
                                BaseText { text: Math.round(parent.dispCpu * 100) + "%"; color: Theme.colors.accent; weight: Theme.typography.weights.bold }
                                BaseText { text: Stats.currentTemp + "°C"; color: Theme.colors.text }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                BaseGraph {
                                    anchors.fill: parent
                                    modelData: Stats.cpuHistory
                                    lineColor: Theme.colors.accent
                                    maxValue: 1.0
                                    autoScale: false
                                    drawProgress: (root.panelState === "Open" || root.panelState === "Opening") ? 1.0 : 0.0
                                }
                            }
                        }
                    }

                    // GPU Block
                    BaseBlock {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 180
                        padding: 0
                        clip: true

                        opacity: (root.panelState === "Open" || root.panelState === "Opening") ? 1.0 : 0.0
                        transform: Translate { y: (root.panelState === "Open" || root.panelState === "Opening") ? 0 : 30 }
                        
                        Behavior on opacity { BaseAnimation { speed: "slow"; delay: 50 } }
                        Behavior on transform { BaseAnimation { speed: "slow"; delay: 50; easing.type: Easing.OutCubic } }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 0

                            RowLayout {
                                property real dispGpu: Stats.currentGpu
                                Behavior on dispGpu { NumberAnimation { duration: 800; easing.type: Easing.OutQuint } }

                                Layout.fillWidth: true
                                Layout.topMargin: Theme.geometry.spacing.dynamicPadding
                                Layout.leftMargin: Theme.geometry.spacing.dynamicPadding
                                Layout.rightMargin: Theme.geometry.spacing.dynamicPadding
                                spacing: Theme.geometry.spacing.small

                                BaseText { text: "GPU"; weight: Theme.typography.weights.bold }
                                Item { Layout.fillWidth: true }
                                BaseText { text: Math.round(parent.dispGpu * 100) + "%"; color: Theme.colors.error; weight: Theme.typography.weights.bold }
                                BaseText { text: Stats.currentGpuTemp + "°C"; color: Theme.colors.text }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                BaseGraph {
                                    anchors.fill: parent
                                    modelData: Stats.gpuHistory
                                    lineColor: Theme.colors.error
                                    maxValue: 1.0
                                    autoScale: false
                                    drawProgress: (root.panelState === "Open" || root.panelState === "Opening") ? 1.0 : 0.0
                                }
                            }
                        }
                    }

                    // ROW 2
                    // RAM Block
                    BaseBlock {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 180
                        padding: 0
                        clip: true

                        opacity: (root.panelState === "Open" || root.panelState === "Opening") ? 1.0 : 0.0
                        transform: Translate { y: (root.panelState === "Open" || root.panelState === "Opening") ? 0 : 30 }
                        
                        Behavior on opacity { BaseAnimation { speed: "slow"; delay: 100 } }
                        Behavior on transform { BaseAnimation { speed: "slow"; delay: 100; easing.type: Easing.OutCubic } }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 0

                            RowLayout {
                                property real dispRam: Stats.currentRam
                                Behavior on dispRam { NumberAnimation { duration: 800; easing.type: Easing.OutQuint } }

                                Layout.fillWidth: true
                                Layout.topMargin: Theme.geometry.spacing.dynamicPadding
                                Layout.leftMargin: Theme.geometry.spacing.dynamicPadding
                                Layout.rightMargin: Theme.geometry.spacing.dynamicPadding
                                spacing: Theme.geometry.spacing.small

                                BaseText { text: "RAM"; weight: Theme.typography.weights.bold }
                                Item { Layout.fillWidth: true }
                                BaseText { text: Math.round(parent.dispRam * 100) + "%"; color: Theme.colors.success; weight: Theme.typography.weights.bold }
                                BaseText { text: Stats.ramText; color: Theme.colors.text }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                BaseGraph {
                                    anchors.fill: parent
                                    modelData: Stats.ramHistory
                                    lineColor: Theme.colors.success
                                    maxValue: 1.0
                                    autoScale: false
                                    drawProgress: (root.panelState === "Open" || root.panelState === "Opening") ? 1.0 : 0.0
                                }
                            }
                        }
                    }

                    // Network Block
                    BaseBlock {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 180
                        padding: 0
                        clip: true

                        opacity: (root.panelState === "Open" || root.panelState === "Opening") ? 1.0 : 0.0
                        transform: Translate { y: (root.panelState === "Open" || root.panelState === "Opening") ? 0 : 30 }
                        
                        Behavior on opacity { BaseAnimation { speed: "slow"; delay: 150 } }
                        Behavior on transform { BaseAnimation { speed: "slow"; delay: 150; easing.type: Easing.OutCubic } }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 0

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.topMargin: Theme.geometry.spacing.dynamicPadding
                                Layout.leftMargin: Theme.geometry.spacing.dynamicPadding
                                Layout.rightMargin: Theme.geometry.spacing.dynamicPadding
                                spacing: Theme.geometry.spacing.small

                                BaseText { text: "NETWORK"; weight: Theme.typography.weights.bold }
                                Item { Layout.fillWidth: true }
                                
                                RowLayout {
                                    property real dispRx: Stats.currentNetworkRx
                                    property real dispTx: Stats.currentNetworkTx
                                    Behavior on dispRx { NumberAnimation { duration: 800; easing.type: Easing.OutQuint } }
                                    Behavior on dispTx { NumberAnimation { duration: 800; easing.type: Easing.OutQuint } }

                                    spacing: Theme.geometry.spacing.medium
                                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                                    
                                    BaseText { 
                                        text: "↓ " + Stats.formatBytes(parent.dispRx) + "/s"
                                        color: Theme.colors.primary 
                                    }
                                    BaseText { 
                                        text: "↑ " + Stats.formatBytes(parent.dispTx) + "/s"
                                        color: Theme.colors.accent 
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                BaseGraph {
                                    anchors.fill: parent
                                    modelData: Stats.networkRxHistory
                                    lineColor: Theme.colors.primary
                                    maxValue: 1024 * 1024 // 1 MB/s initially, auto scales up natively
                                    autoScale: true
                                    drawProgress: (root.panelState === "Open" || root.panelState === "Opening") ? 1.0 : 0.0
                                }
                                
                                BaseGraph {
                                    anchors.fill: parent
                                    modelData: Stats.networkTxHistory
                                    lineColor: Theme.colors.accent
                                    maxValue: 1024 * 1024
                                    autoScale: true
                                    drawProgress: (root.panelState === "Open" || root.panelState === "Opening") ? 1.0 : 0.0
                                }
                            }
                        }
                    }

                    // ROW 3
                    // Disk I/O Block (Spans 2 columns to sit on row 3 elegantly)
                    BaseBlock {
                        Layout.fillWidth: true
                        Layout.columnSpan: 2
                        Layout.preferredHeight: 180
                        padding: 0
                        clip: true

                        opacity: (root.panelState === "Open" || root.panelState === "Opening") ? 1.0 : 0.0
                        transform: Translate { y: (root.panelState === "Open" || root.panelState === "Opening") ? 0 : 30 }
                        
                        Behavior on opacity { BaseAnimation { speed: "slow"; delay: 200 } }
                        Behavior on transform { BaseAnimation { speed: "slow"; delay: 200; easing.type: Easing.OutCubic } }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 0

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.topMargin: Theme.geometry.spacing.dynamicPadding
                                Layout.leftMargin: Theme.geometry.spacing.dynamicPadding
                                Layout.rightMargin: Theme.geometry.spacing.dynamicPadding
                                spacing: Theme.geometry.spacing.small

                                BaseText { text: "DISK"; weight: Theme.typography.weights.bold }
                                Item { Layout.fillWidth: true }
                                
                                RowLayout {
                                    property real dispRead: Stats.currentDiskRead
                                    property real dispWrite: Stats.currentDiskWrite
                                    Behavior on dispRead { NumberAnimation { duration: 800; easing.type: Easing.OutQuint } }
                                    Behavior on dispWrite { NumberAnimation { duration: 800; easing.type: Easing.OutQuint } }

                                    spacing: Theme.geometry.spacing.medium
                                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                                    
                                    BaseText { 
                                        text: "R: " + Stats.formatBytes(parent.dispRead) + "/s"
                                        color: Theme.colors.warning 
                                    }
                                    BaseText { 
                                        text: "W: " + Stats.formatBytes(parent.dispWrite) + "/s"
                                        color: Theme.colors.error 
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                BaseGraph {
                                    anchors.fill: parent
                                    modelData: Stats.diskReadHistory
                                    lineColor: Theme.colors.warning
                                    maxValue: 1024 * 1024 * 10 // 10 MB/s base scale
                                    autoScale: true
                                    drawProgress: (root.panelState === "Open" || root.panelState === "Opening") ? 1.0 : 0.0
                                }
                                
                                BaseGraph {
                                    anchors.fill: parent
                                    modelData: Stats.diskWriteHistory
                                    lineColor: Theme.colors.error
                                    maxValue: 1024 * 1024 * 10
                                    autoScale: true
                                    drawProgress: (root.panelState === "Open" || root.panelState === "Opening") ? 1.0 : 0.0
                                }
                            }
                        }
                    }
                }
            }

            // Unified Drives List (Sorted: Internal first, then External)
            Repeater {
                model: Stats.drives || []
                delegate: DriveCard {}
            }

            component DriveCard: BaseBlock {
                id: driveCard
                Layout.fillWidth: true

                opacity: (root.panelState === "Open" || root.panelState === "Opening") ? 1.0 : 0.0
                transform: Translate { y: (root.panelState === "Open" || root.panelState === "Opening") ? 0 : 30 }
                
                Behavior on opacity { BaseAnimation { speed: "slow"; delay: 250 } }
                Behavior on transform { BaseAnimation { speed: "slow"; delay: 250; easing.type: Easing.OutCubic } }

                // Alias roles defensively
                readonly property var driveData: modelData || {}
                readonly property var partitionsData: driveData.partitions || []
                readonly property real totalSize: driveData.totalSizeBytes || 0
                readonly property real totalUsed: driveData.totalUsedBytes || 0
                readonly property bool isExternal: !!driveData.removable

                clickable: true
                onClicked: {
                    if (driveCard.partitionsData.length > 0 && driveCard.partitionsData[0].mount) {
                        ProcessService.runDetached(["xdg-open", driveCard.partitionsData[0].mount]);
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.geometry.spacing.medium

                    // Drive Header
                    RowLayout {
                        Layout.fillWidth: true
                        
                        RowLayout {
                            spacing: Theme.geometry.spacing.small
                            Layout.fillWidth: true

                            BaseText {
                                text: driveCard.driveData.name || "Unknown Drive"
                                weight: Theme.typography.weights.bold
                                pixelSize: Theme.typography.size.large
                            }

                            // Filesystem Tag

                            Rectangle {
                                visible: !!driveCard.driveData.filesystem
                                height: 16
                                width: fsText.width + 8
                                radius: Theme.geometry.radius * 0.2
                                color: Theme.alpha(Theme.colors.primary, 0.1)
                                border.color: Theme.alpha(Theme.colors.primary, 0.2)
                                
                                BaseText {
                                    id: fsText
                                    anchors.centerIn: parent
                                    text: (driveCard.driveData.filesystem || "").toUpperCase()
                                    pixelSize: Theme.typography.size.small - 1
                                    weight: Theme.typography.weights.bold
                                    color: Theme.colors.primary
                                }
                            }

                            Item { Layout.fillWidth: true }

                            BaseText {
                                text: (driveCard.driveData.used || "0 B") + " / " + (driveCard.driveData.size || "0 B")
                                color: Theme.colors.text
                                pixelSize: Theme.typography.size.base
                            }
                        }
                    }

                    // Unified Progress Bar
                    Rectangle {
                        id: barContainer
                        Layout.fillWidth: true
                        Layout.preferredHeight: 12
                        radius: Math.max(2, Theme.geometry.radius * 0.5)
                        color: Theme.alpha(Theme.colors.text, 0.05)
                        clip: true

                        Rectangle {
                            id: usageFill
                            height: parent.height
                            width: driveCard.totalSize > 0 ? (driveCard.totalUsed / driveCard.totalSize) * parent.width : 0
                            radius: 2
                            color: {
                                var p = driveCard.totalSize > 0 ? (driveCard.totalUsed / driveCard.totalSize) : 0;
                                if (p > 0.8) return Theme.colors.error;
                                if (p > 0.5) return Theme.colors.warning;
                                return Theme.colors.primary;
                            }
                            opacity: 0.8
                        }
                    }

                    // Partitions List - Hidden if only 1 partition
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        visible: driveCard.partitionsData.length > 1
                        
                        Repeater {
                            model: driveCard.partitionsData
                            delegate: RowLayout {
                                readonly property var pInfo: modelData || {}
                                readonly property real pPercent: pInfo.percent || 0

                                Layout.fillWidth: true
                                spacing: Theme.geometry.spacing.medium
                                
                                Rectangle {
                                    width: 8
                                    height: 8
                                    radius: 2
                                    color: {
                                        if (pPercent > 0.8) return Theme.colors.error;
                                        if (pPercent > 0.5) return Theme.colors.warning;
                                        return Theme.colors.primary;
                                    }
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                BaseText {
                                    text: pInfo.label || "Unknown"
                                    weight: Theme.typography.weights.medium
                                    pixelSize: 13
                                    Layout.preferredWidth: 120
                                    elide: Text.ElideRight
                                }

                                BaseText {
                                    text: pInfo.mount || ""
                                    color: Theme.colors.muted
                                    pixelSize: 11
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }

                                Item { Layout.fillWidth: true }

                                BaseText {
                                    text: Math.round(pPercent * 100) + "%"
                                    color: pPercent > 0.8 ? Theme.colors.error : Theme.colors.text
                                    pixelSize: 11
                                    weight: Theme.typography.weights.bold
                                    Layout.preferredWidth: 40
                                    horizontalAlignment: Text.AlignRight
                                    visible: Math.round(pPercent * 100) > 0
                                }

                                BaseText {
                                    text: (pInfo.used || "0") + " / " + (pInfo.size || "0")
                                    pixelSize: 11
                                    color: Theme.colors.text
                                    Layout.alignment: Qt.AlignRight
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
