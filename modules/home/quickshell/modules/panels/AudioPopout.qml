import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs

BasePopoutWindow {
    id: root

    panelNamespace: "quickshell:audio-popout"
    
    property bool outputsExpanded: false
    property bool inputsExpanded: false

    body: ScrollView {
        implicitWidth: 420
        contentWidth: availableWidth
        implicitHeight: col.implicitHeight
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        ColumnLayout {
            id: col
            width: parent.width
            spacing: Theme.geometry.spacing.large

            // Audio Sliders (Output & Input)
            BaseBlock {
                Layout.fillWidth: true

                BaseSlider {
                    id: outputSlider

                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    trackHeight: 38
                    icon: Volume.volumeIcon
                    suffix: Math.round(Volume.volume * 100)
                    iconColor: Theme.colors.text
                    suffixColor: Theme.colors.text
                    iconSize: Theme.dimensions.iconMedium
                    fontSize: Theme.typography.size.base
                    from: 0
                    to: 1
                    stepSize: 0.01
                    onValueChangedByUser: Volume.setVolume(value)
                    onIconClicked: Volume.toggleMute()

                    Binding on value {
                        value: Volume.volume
                        when: !outputSlider.pressed
                        restoreMode: Binding.RestoreBinding
                    }
                }

                BaseSlider {
                    id: inputSlider

                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    trackHeight: 38
                    icon: Volume.inputMuted ? "mic_off" : "mic"
                    suffix: Math.round(Volume.inputVolume * 100)
                    iconColor: Theme.colors.text
                    suffixColor: Theme.colors.text
                    iconSize: Theme.dimensions.iconMedium
                    fontSize: Theme.typography.size.base
                    from: 0
                    to: 1
                    stepSize: 0.01
                    onValueChangedByUser: Volume.setInputVolume(value)
                    onIconClicked: Volume.toggleInputMute()

                    Binding on value {
                        value: Volume.inputVolume
                        when: !inputSlider.pressed
                        restoreMode: Binding.RestoreBinding
                    }
                }
            }



            // Output Devices
            BaseBlock {
                title: "Outputs"
                Layout.fillWidth: true
                clickable: true
                hoverEnabled: false
                paddingVertical: root.outputsExpanded ? Theme.geometry.spacing.dynamicPadding : Theme.geometry.spacing.medium
                spacing: root.outputsExpanded ? Theme.geometry.spacing.medium : 0
                onClicked: root.outputsExpanded = !root.outputsExpanded

                headerItem: BaseIcon {
                    icon: root.outputsExpanded ? "expand_less" : "expand_more"
                    color: Theme.colors.muted
                    size: Theme.dimensions.iconBase
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.outputsExpanded ? outputsContent.implicitHeight : 0
                    clip: true
                    opacity: root.outputsExpanded ? 1 : 0
                    visible: root.outputsExpanded || opacity > 0

                    Behavior on Layout.preferredHeight { BaseAnimation { duration: Theme.animations.fast } }
                    Behavior on opacity { BaseAnimation { duration: Theme.animations.fast } }

                    ColumnLayout {
                        id: outputsContent
                        width: parent.width
                        spacing: Theme.geometry.spacing.small

                        Repeater {
                            model: Volume.sinks
                            delegate: BaseButton {
                                id: sinkButton
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                gradient: true
                                selected: (Volume.audioSink && Volume.audioSink.id === modelData.id) || containsMouse
                                normalColor: Theme.colors.transparent
                                hoverColor: Theme.colors.transparent
                                contentAlignment: Qt.AlignLeft
                                paddingHorizontal: Theme.geometry.spacing.dynamicPadding
                                onClicked: Volume.selectSink(modelData.id)

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: parent.paddingHorizontal
                                    anchors.rightMargin: parent.paddingHorizontal
                                    spacing: Theme.geometry.spacing.medium

                                    BaseIcon {
                                        icon: "speaker"
                                        color: sinkButton.iconColor
                                        size: Theme.dimensions.iconMedium
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        Layout.alignment: Qt.AlignVCenter

                                        BaseText {
                                            text: Volume.getNodeName(modelData)
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                            color: sinkButton.textColor
                                            weight: sinkButton.weight
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Input Devices
            BaseBlock {
                title: "Inputs"
                Layout.fillWidth: true
                clickable: true
                hoverEnabled: false
                paddingVertical: root.inputsExpanded ? Theme.geometry.spacing.dynamicPadding : Theme.geometry.spacing.medium
                spacing: root.inputsExpanded ? Theme.geometry.spacing.medium : 0
                onClicked: root.inputsExpanded = !root.inputsExpanded

                headerItem: BaseIcon {
                    icon: root.inputsExpanded ? "expand_less" : "expand_more"
                    color: Theme.colors.muted
                    size: Theme.dimensions.iconBase
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.inputsExpanded ? inputsContent.implicitHeight : 0
                    clip: true
                    opacity: root.inputsExpanded ? 1 : 0
                    visible: root.inputsExpanded || opacity > 0

                    Behavior on Layout.preferredHeight { BaseAnimation { duration: Theme.animations.fast } }
                    Behavior on opacity { BaseAnimation { duration: Theme.animations.fast } }

                    ColumnLayout {
                        id: inputsContent
                        width: parent.width
                        spacing: Theme.geometry.spacing.small

                        Repeater {
                            model: Volume.sources
                            delegate: BaseButton {
                                id: sourceButton
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                gradient: true
                                selected: (Volume.audioSource && Volume.audioSource.id === modelData.id) || containsMouse
                                normalColor: Theme.colors.transparent
                                hoverColor: Theme.colors.transparent
                                contentAlignment: Qt.AlignLeft
                                paddingHorizontal: Theme.geometry.spacing.dynamicPadding
                                onClicked: Volume.selectSource(modelData.id)

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: parent.paddingHorizontal
                                    anchors.rightMargin: parent.paddingHorizontal
                                    spacing: Theme.geometry.spacing.medium

                                    BaseIcon {
                                        icon: "mic"
                                        color: sourceButton.iconColor
                                        size: Theme.dimensions.iconMedium
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    BaseText {
                                        text: Volume.getNodeName(modelData)
                                        weight: sourceButton.weight
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                        color: sourceButton.textColor
                                        Layout.alignment: Qt.AlignVCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Application Volume Control
            BaseBlock {
                title: "Applications"
                Layout.fillWidth: true
                visible: Volume.apps.length > 0

                Repeater {
                    model: Volume.apps
                    delegate: RowLayout {
                        id: appDelegate
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        spacing: Theme.geometry.spacing.medium
                        visible: modelData.ready && Volume.getAppName(modelData) !== ""

                        PwObjectTracker { objects: [modelData] }

                        Item {
                            Layout.preferredWidth: Theme.dimensions.iconLarge
                            Layout.preferredHeight: Theme.dimensions.iconLarge
                            Layout.alignment: Qt.AlignVCenter

                            BaseIcon {
                                anchors.fill: parent
                                color: Theme.colors.text
                                text: Volume.getAppName(modelData)
                                showFallback: true
                                fallbackChar: {
                                    var name = Volume.getAppName(modelData);
                                    return (name && name.length > 0) ? name.charAt(0).toUpperCase() : "?";
                                }
                                size: Theme.dimensions.iconLarge
                                visible: !appIcon.visible
                            }

                            Image {
                                id: appIcon
                                anchors.fill: parent
                                source: LauncherService.resolveIcon(Volume.getAppIcon(modelData))
                                fillMode: Image.PreserveAspectFit
                                visible: status === Image.Ready && width > 0
                            }
                        }

                        BaseText {
                            text: Volume.getAppName(modelData)
                            elide: Text.ElideRight
                            Layout.preferredWidth: 120
                            color: Theme.colors.text
                            Layout.alignment: Qt.AlignVCenter
                        }

                        BaseButton {
                            Layout.preferredWidth: Theme.dimensions.iconLarge
                            Layout.preferredHeight: Theme.dimensions.iconLarge
                            Layout.alignment: Qt.AlignVCenter
                            normalColor: Theme.colors.transparent
                            hoverColor: Theme.colors.background
                            activeColor: Theme.colors.background
                            icon: (modelData.audio && modelData.audio.muted) ? "volume_off" : "volume_up"
                            iconColor: (modelData.audio && modelData.audio.muted) ? Theme.colors.error : Theme.colors.muted
                            iconSize: Theme.dimensions.iconMedium
                            onClicked: Volume.toggleAppMute(modelData.id)
                        }

                        BaseSlider {
                            id: appVolumeSlider
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            from: 0
                            to: 1
                            stepSize: 0.01
                            enabled: modelData.audio !== null && modelData.ready
                            onValueChangedByUser: {
                                if (modelData.audio && modelData.ready)
                                    modelData.audio.volume = value;
                            }

                            Binding on value {
                                value: (modelData.audio) ? modelData.audio.volume : 0
                                when: !appVolumeSlider.pressed
                                restoreMode: Binding.RestoreBinding
                            }
                        }

                        BaseText {
                            text: Math.round(appVolumeSlider.value * 100) + "%"
                            Layout.preferredWidth: 40
                            horizontalAlignment: Text.AlignRight
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                }
            }
        }
    }
}
